import Foundation

// Мост для использования RuleConverter из основного приложения
// Этот файл позволяет основному приложению использовать функциональность конвертера

class RuleConverterBridge {
    
    /// Конвертирует правила блокировки в JSON формат
    /// - Parameter rules: Массив строк с правилами
    /// - Returns: JSON строка
    static func convertRules(_ rules: [String]) -> String {
        // Здесь будет вызов RuleConverter из расширения
        // Пока возвращаем заглушку
        return "[]"
    }
    
    /// Сохраняет правила в память устройства
    /// - Parameters:
    ///   - jsonString: JSON строка для сохранения
    ///   - filename: Имя файла
    /// - Returns: true если сохранение прошло успешно
    static func saveRules(_ jsonString: String, filename: String = "converted_blockerList") -> Bool {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        
        let fileURL = documentsPath.appendingPathComponent("\(filename).json")
        
        do {
            try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }
    
    /// Загружает правила из памяти устройства
    /// - Parameter filename: Имя файла
    /// - Returns: JSON строка или nil
    static func loadRules(filename: String = "converted_blockerList") -> String? {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentsPath.appendingPathComponent("\(filename).json")
        
        do {
            return try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
