#include <windows.h>
#include <string>

extern "C" __declspec(dllexport) int connect_to_printer(const char* printerPort) {
    HANDLE hPrinter = CreateFile(
        printerPort,            // Имя порта (например, "USB001")
        GENERIC_WRITE,          // Открытие для записи
        0,                      // Без совместного доступа
        NULL,                   // Защита по умолчанию
        OPEN_EXISTING,          // Открыть существующий порт
        FILE_ATTRIBUTE_NORMAL,  // Обычный файл
        NULL                    // Нет шаблонного файла
    );

    if (hPrinter == INVALID_HANDLE_VALUE) {
        return -1;  // Ошибка подключения
    }

    return (int)hPrinter;  // Возвращаем дескриптор принтера
}

extern "C" __declspec(dllexport) bool send_tspl_command(int printerHandle, const char* command) {
    HANDLE hPrinter = (HANDLE)printerHandle;
    DWORD bytesWritten;
    bool result = WriteFile(
        hPrinter,           // Дескриптор принтера
        command,            // Команда TSPL
        strlen(command),    // Длина команды
        &bytesWritten,      // Количество отправленных байт
        NULL                // Нет асинхронной записи
    );

    return result && (bytesWritten == strlen(command));
}

extern "C" __declspec(dllexport) void disconnect_printer(int printerHandle) {
    CloseHandle((HANDLE)printerHandle);
}
