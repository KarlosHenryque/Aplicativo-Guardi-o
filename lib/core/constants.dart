// Contrato com o relógio (ESP32): mesmos valores no firmware.
const kServiceUuid = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
const kNotifyCharUuid = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';
const kFallMessage = 'QUEDA';

// Tempo que a pessoa tem para responder antes de acionar a emergência.
const kResponseSeconds = 30;
