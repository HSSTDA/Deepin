import SwiftUI

struct DailyNoteView: View {
    
    @EnvironmentObject var localization: LocalizationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var noteText: String = ""
    @State private var saved = false
    @FocusState private var isFocused: Bool
    
    let maxChars = 120
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // MARK: - Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Text(localization.isArabic ? "إغلاق" : "Close")
                            .font(.system(size: 14, weight: .light))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    
                    Spacer()
                    
                    Text(localization.isArabic ? "ملاحظة اليوم" : "Today's Note")
                        .font(.system(size: 13, weight: .light))
                        .tracking(4)
                        .foregroundStyle(.white.opacity(0.4))
                    
                    Spacer()
                    
                    // placeholder للمحاذاة
                    Text(localization.isArabic ? "إغلاق" : "Close")
                        .opacity(0)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                Spacer()
                
                // MARK: - الكرة الصغيرة
                DeepSphere(decayLevel: 0.0)
                    .scaleEffect(0.5)
                    .frame(width: 110, height: 110)
                    .opacity(0.7)
                
                Spacer().frame(height: 32)
                
                // MARK: - السؤال
                VStack(spacing: 8) {
                    Text(localization.isArabic ? "كيف كان يومك؟" : "How was your day?")
                        .font(.system(size: 22, weight: .thin))
                        .foregroundStyle(.white.opacity(0.85))
                    
                    Text(localization.isArabic
                         ? "جملة واحدة تكفي"
                         : "One sentence is enough")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(.white.opacity(0.3))
                }
                
                Spacer().frame(height: 32)
                
                // MARK: - حقل الكتابة
                VStack(spacing: 8) {
                    ZStack(alignment: .topLeading) {
                        
                        // Placeholder
                        if noteText.isEmpty {
                            Text(localization.isArabic
                                 ? "اكتب هنا..."
                                 : "Write here...")
                                .font(.system(size: 16, weight: .light))
                                .foregroundStyle(.white.opacity(0.15))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
                        }
                        
                        // حقل النص
                        TextEditor(text: $noteText)
                            .font(.system(size: 16, weight: .light))
                            .foregroundStyle(.white.opacity(0.8))
                            .scrollContentBackground(.hidden)
                            .background(.clear)
                            .focused($isFocused)
                            .frame(minHeight: 80, maxHeight: 120)
                            .onChange(of: noteText) {
                                // (1) حد أقصى للحروف
                                if noteText.count > maxChars {
                                    noteText = String(noteText.prefix(maxChars))
                                }
                            }
                    }
                    .padding(16)
                    .background(.white.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // عداد الحروف
                    HStack {
                        Spacer()
                        Text("\(noteText.count)/\(maxChars)")
                            .font(.system(size: 10, weight: .light).monospacedDigit())
                            .foregroundStyle(.white.opacity(0.2))
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // MARK: - زر الحفظ
                if saved {
                    // تأكيد الحفظ
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .light))
                        Text(localization.isArabic ? "تم الحفظ" : "Saved")
                            .font(.system(size: 14, weight: .light))
                            .tracking(2)
                    }
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.bottom, 56)
                    
                } else {
                    Button {
                        guard !noteText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        DailyNoteManager.saveNote(noteText)
                        isFocused = false
                        withAnimation(.easeInOut(duration: 0.3)) {
                            saved = true
                        }
                        // إغلاق بعد ثانيتين
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    } label: {
                        Text(localization.isArabic ? "حفظ" : "Save")
                            .font(.system(size: 15, weight: .light))
                            .tracking(2)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(.white.opacity(noteText.isEmpty ? 0.3 : 0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                    }
                    .disabled(noteText.isEmpty)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 56)
                }
            }
        }
        .environment(\.layoutDirection, localization.isArabic ? .rightToLeft : .leftToRight)
        .onAppear {
            // (2) نحمل الملاحظة الموجودة إذا كتب اليوم
            if let existing = DailyNoteManager.loadTodayNote() {
                noteText = existing
            }
            // نفتح الكيبورد تلقائياً
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }
}

#Preview {
    DailyNoteView()
        .environmentObject(LocalizationManager.shared)
}
