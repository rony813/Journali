//
//  SpeechSearchViewModel.swift
//  journali
//
//  Created by RON on 06/06/1448 AH.
//

import Foundation
import Combine
import Speech
import AVFoundation

@MainActor
final class SpeechSearchViewModel: ObservableObject {
    // حالة التسجيل والنص الناتج.
    @Published private(set) var isRecording = false
    @Published private(set) var isStarting = false
    @Published private(set) var transcript = ""

    // رسالة الخطأ المعروضة في الواجهة.
    @Published var errorMessage: String?

    private let audioEngine = AVAudioEngine()

    // التعرّف على الكلام بلغة الجهاز.
    private let recognizer = SFSpeechRecognizer(
        locale: Locale.current
    )

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    private var hasAudioTap = false
    private var isAudioSessionActive = false
    private var sessionID = UUID()

    func toggleRecording() async {
        if isRecording {
            stopRecording()
            return
        }

        guard !isStarting else { return }

        errorMessage = nil

        // التأكد من إضافة أوصاف الأذونات في إعدادات التطبيق.
        guard hasPrivacyDescriptions else {
            errorMessage =
                "Add Microphone and Speech Recognition usage descriptions in the app's Info settings."
            return
        }

        isStarting = true
        defer { isStarting = false }

        let startingSessionID = sessionID

        // طلب إذن التعرّف على الكلام.
        let speechStatus = await withCheckedContinuation {
            (continuation: CheckedContinuation<
                SFSpeechRecognizerAuthorizationStatus,
                Never
            >) in

            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }

        // عدم بدء التسجيل إذا أُلغيت العملية أثناء طلب الإذن.
        guard sessionID == startingSessionID else { return }

        guard speechStatus == .authorized else {
            errorMessage =
                "Allow Speech Recognition in Settings to use voice search."
            return
        }

        // الطريقة الحديثة لطلب إذن المايك.
        let microphoneAllowed = await withCheckedContinuation {
            (continuation: CheckedContinuation<Bool, Never>) in

            AVAudioApplication.requestRecordPermission { allowed in
                continuation.resume(returning: allowed)
            }
        }

        guard sessionID == startingSessionID else { return }

        guard microphoneAllowed else {
            errorMessage =
                "Allow Microphone access in Settings to use voice search."
            return
        }

        guard let recognizer, recognizer.isAvailable else {
            errorMessage =
                "Voice search is currently unavailable. Please try again."
            return
        }

        do {
            try startRecording(using: recognizer)
        } catch {
            stopRecording()
            errorMessage =
                "Couldn't start voice search. \(error.localizedDescription)"
        }
    }

    // يفحص وجود نصوص الخصوصية قبل طلب الأذونات.
    private var hasPrivacyDescriptions: Bool {
        let keys = [
            "NSMicrophoneUsageDescription",
            "NSSpeechRecognitionUsageDescription"
        ]

        return keys.allSatisfy { key in
            guard let description = Bundle.main
                .object(forInfoDictionaryKey: key) as? String else {
                return false
            }

            return !description
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty
        }
    }

    private func startRecording(
        using recognizer: SFSpeechRecognizer
    ) throws {
        // تنظيف أي تسجيل سابق.
        stopRecording()
        transcript = ""

        let audioSession = AVAudioSession.sharedInstance()

        try audioSession.setCategory(
            .record,
            mode: .measurement,
            options: .duckOthers
        )

        try audioSession.setActive(true)
        isAudioSessionActive = true

        // التأكد من وجود مدخل صوت.
        guard audioSession.isInputAvailable else {
            throw NSError(
                domain: "VoiceSearch",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "No microphone input is available."
                ]
            )
        }

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        // التأكد من صلاحية إعدادات الصوت.
        guard format.sampleRate > 0,
              format.channelCount > 0 else {
            throw NSError(
                domain: "VoiceSearch",
                code: 2,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "The microphone audio format is unavailable."
                ]
            )
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        // إرسال صوت المايك إلى خدمة التعرّف.
        inputNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: format
        ) { buffer, _ in
            request.append(buffer)
        }

        hasAudioTap = true

        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true

        let currentSessionID = sessionID

        recognitionTask = recognizer.recognitionTask(
            with: request
        ) { [weak self] result, error in
            let text = result?.bestTranscription.formattedString
            let isFinal = result?.isFinal ?? false
            let failed = error != nil

            Task { @MainActor [weak self] in
                guard let self,
                      self.isRecording,
                      self.sessionID == currentSessionID else {
                    return
                }

                // تحديث البحث أثناء الكلام.
                if let text {
                    self.transcript = text
                }

                if isFinal {
                    self.stopRecording()
                } else if failed {
                    self.stopRecording()
                    self.errorMessage =
                        "Voice search stopped. Please try again."
                }
            }
        }
    }

    func stopRecording() {
        // إلغاء الجلسة وإيقاف استقبال الصوت.
        sessionID = UUID()
        isRecording = false

        audioEngine.stop()

        if hasAudioTap {
            audioEngine.inputNode.removeTap(onBus: 0)
            hasAudioTap = false
        }

        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        recognitionRequest = nil
        recognitionTask = nil

        // تحرير جلسة الصوت بعد استخدامها.
        if isAudioSessionActive {
            try? AVAudioSession.sharedInstance().setActive(
                false,
                options: .notifyOthersOnDeactivation
            )

            isAudioSessionActive = false
        }
    }
}
