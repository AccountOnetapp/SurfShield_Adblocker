# Конвертер правил блокировки рекламы

Этот модуль позволяет конвертировать правила блокировки рекламы из текстового формата в JSON формат для Content Blocker Extension iOS.

## Как это работает

### 1. Формат исходных правил
Правила поддерживают синтаксис AdBlock Plus:
- `-contrib-ads.$~stylesheet` - блокирует CSS файлы с именем contrib-ads
- `.adriver.$~object,domain=~adriver.co` - блокирует объекты adriver, кроме домена adriver.co
- `.ads.controller.js$script` - блокирует JavaScript файлы ads.controller.js
- `.advert.$domain=~advert.ae|~advert.ge` - блокирует рекламу на всех доменах, кроме указанных

### 2. Поддерживаемые модификаторы
- `$script` - блокирует только JavaScript файлы
- `$image` - блокирует только изображения
- `$stylesheet` - блокирует только CSS файлы
- `$xmlhttprequest` - блокирует только AJAX запросы
- `$third-party` - блокирует только сторонние ресурсы
- `$object` - блокирует только объекты (Flash, Java и т.д.)
- `domain=~example.com` - применяет правило только к указанным доменам
- `~example.com` - исключает домен из правила

### 3. Конвертация в JSON
Каждое правило конвертируется в формат:
```json
{
    "trigger": {
        "url-filter": "pattern",
        "resource-type": ["script"],
        "if-domain": ["example.com"]
    },
    "action": {
        "type": "block"
    }
}
```

## Использование

### Автоматическая конвертация
```swift
// Загружаем правила из файла
let rulesPath = Bundle.main.path(forResource: "adblock_rules", ofType: "txt")!
let rulesContent = try! String(contentsOfFile: rulesPath, encoding: .utf8)
let rules = rulesContent.components(separatedBy: .newlines)

// Конвертируем в JSON
let jsonString = RuleConverter.convertRulesToJSON(rules)

// Сохраняем в память устройства
RuleConverter.saveRulesToDevice(jsonString, filename: "converted_blockerList")
```

### Ручная конвертация
```swift
// Создаем правила вручную
let customRules = [
    ".ads.$script",
    ".banner.$image",
    ".popup.$popup"
]

let jsonString = RuleConverter.convertRulesToJSON(customRules)
```

### Загрузка правил
```swift
// Загружаем из памяти устройства
if let rules = RuleConverter.loadRulesFromDevice(filename: "converted_blockerList") {
    print("Правила загружены: \(rules)")
}
```

## Преимущества

1. **Экономия места**: JSON формат более компактен чем текстовый
2. **Производительность**: Быстрая загрузка и парсинг
3. **Гибкость**: Легко добавлять новые правила и модификаторы
4. **Совместимость**: Полная совместимость с Content Blocker Extension
5. **Кэширование**: Правила сохраняются в памяти устройства

## Структура файлов

- `RuleConverter.swift` - основной класс конвертера
- `RuleConverterTest.swift` - тестирование и демонстрация
- `adblock_rules.txt` - исходные правила блокировки
- `ContentBlockerRequestHandler.swift` - обработчик запросов с поддержкой динамических правил

## Тестирование

Запустите `RuleConverterTest.testConversion()` для проверки работы конвертера:
```swift
RuleConverterTest.testConversion()
RuleConverterTest.compareFileSizes()
```

## Примечания

- Правила автоматически валидируются при конвертации
- Некорректные правила пропускаются
- Поддерживается комментарии (строки начинающиеся с // или #)
- Пустые строки игнорируются
