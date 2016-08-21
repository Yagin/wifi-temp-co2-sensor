-- Пин на котором висит DHT
gDHTpin = 5;
-- Пин на котором висит тадчик CO2
gCo2pin = 2;
-- Значение CO2
gPPM    = 0;
-- Значение температуры
gTemp   = 0;
-- Значение влажности
gHumi   = 0;
-- Адрес php скрипта для GET запроса.
-- вызов будет выглядеть следующим образом
-- http://www.my-site.com/my-get.php?ppm=545&temp=24&humi=40
gURL    = "http://www.yagin.kz/get-sensor-data.php";
-- Частота опроса датчиков
gFreqSensReading = 15000;
-- Файл конфигураций
gConfgiFile = "my-config.cfg";
-- Список доступных точек-доступа как табдлица HTML (SSID,MAC) 
gAPList = "";
-- Флаг возможности отправки данных на сервер
gCanSend = false;
-- Время задержки перед началом отправки данных на сервер 
-- (после запуска устройства). Данная задержка необходима поскольку 
-- датчику MH-Z19 нужно 3 минуты для разогрева, только после этого времени 
-- данным можно доверять.
gDelayBefSending = 180000;
-- Есть ли подключение к точке доступа
gAPConnectAvail = false; 
-- Интервал с которым проверять подключен ли интернет
gAPConnectChkTime = 300000; -- 5 минут

-- Таймеры
-- Идентификатор таймера для проверки наличия подключения
-- и запуска процедуры отправки данных
gIdntTmrStartSendData = 0
-- Идентификатор таймера на подключение к AP
gIdntTmrConnAP = 1
-- Идентификатор таймера чтения данных с датчиков
gIdntTmrSensReading = 2
-- Идентификатор таймера определения "честных" данных
gIdntTmrTrustedData = 3
