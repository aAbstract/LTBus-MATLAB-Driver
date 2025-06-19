classdef LTBD_Request_U16 < matlab.System
    % LTBD_Sensor: Simulink block to interface with LabTronic hardware sensors

    properties
        LT_BUS_DEVICE_PORT = '/dev/ttyUSB0';
        LT_BUS_DEVICE_BAUD_RATE = 115200;
        LT_BUS_DEVICE_REGISTER_ADDRESS = 0xD000;
    end

    properties (Access = private)
        ltbus_device;
        ltbus_driver;
    end

    methods (Access = protected)
        function setupImpl(obj)
            coder.extrinsic('serialport', 'LTBusDriver');
            obj.ltbus_device = serialport(obj.LT_BUS_DEVICE_PORT, obj.LT_BUS_DEVICE_BAUD_RATE);
            obj.ltbus_driver = LTBusDriver();
        end

        function [rc, u16_value] = stepImpl(obj)
            coder.extrinsic('write', 'read');
            req = obj.ltbus_driver.read_request(obj.LT_BUS_DEVICE_REGISTER_ADDRESS, 2);
            write(obj.ltbus_device, req, "uint8");
            res = read(obj.ltbus_device, 12, "uint8");
            [rc, u16_value] = obj.ltbus_driver.decode_u16(res);
        end

        function resetImpl(~)
        end

        function flag = supportsCodeGenerationImpl(~)
            flag = false;
        end
    end
end
