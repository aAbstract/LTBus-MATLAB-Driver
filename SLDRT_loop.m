clear;

ltbus_device = serialport('/dev/ttyACM0', 115200);
ltbus_driver = LTBusDriver();

function [rc, u16_value] = request_u16(device, driver, address)
req = driver.read_request(address, 2);
write(device, req, 'uint8');
res = read(device, 12, 'uint8');
[rc, u16_value] = driver.decode_u16(res);
end

MAG_ENC_CH1_tcp_channel = tcpserver('127.0.0.1', 6500);
while true
    if MAG_ENC_CH1_tcp_channel.Connected
        [~, u16_value] = request_u16(ltbus_device, ltbus_driver, 0xD024);
        write(MAG_ENC_CH1_tcp_channel, sprintf("%d\n", u16_value), "string");
    end
    pause(1E-3);
end
