clear;

ltbus_driver = LTBusDriver();
sp = serialport('/dev/ttyACM0', 115200);

MAG_ENC_CH1_req = ltbus_driver.read_request(0xD024, 2);
write(sp, MAG_ENC_CH1_req, 'uint8');
MAG_ENC_CH1_res = read(sp, 12, 'uint8');
[rc, MAG_ENC_CH1_val] = ltbus_driver.decode_u16(MAG_ENC_CH1_res);
disp(MAG_ENC_CH1_val * (360 / 4095));
