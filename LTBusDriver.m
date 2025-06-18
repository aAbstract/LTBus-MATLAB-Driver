classdef LTBusDriver
    properties (Constant)
        DEFAULT_SLAVE_ID = 1;

        LT_BUS_READ_FC = 0xAA;
        LT_BUS_WRITE_FC = 0xEA;
        LT_BUS_READ_RESP_FC = 0xAB;

        LT_BUS_RC_OK = 0;
        LT_BUS_RC_ERR_UNK_FC = 1;
        LT_BUS_RC_ERR_INV_CRC16 = 2;
        LT_BUS_RC_ERR_SLV_ID_MISMATCH = 3;

        LT_BUS_PACKET_HEADER_SIZE = 3;
        LT_BUS_PACKET_FOOTER_SIZE = 3;

        CRC16_POLYNOMIAL = LTBusDriver.initCRC16Table()
    end

    methods (Static)
        function crc = compute_crc16(data)
            crc = uint16(65535); % 0xFFFF
            for i = 1:length(data)
                idx = bitxor(bitand(crc, 255), uint16(data(i))) + 1;
                crc = bitxor(bitshift(crc, -8), LTBusDriver.CRC16_POLYNOMIAL(idx));
            end
            crc = bitcmp(crc);
        end

        function packet = read_request(address, data_size)
            packet = zeros(1, 10, 'uint8');
            packet(1) = 0x7B;
            packet(2) = LTBusDriver.DEFAULT_SLAVE_ID;
            packet(3) = LTBusDriver.LT_BUS_READ_FC;
            packet(4:5) = typecast(uint16(address), 'uint8');
            packet(6:7) = typecast(uint16(data_size), 'uint8');

            crc = LTBusDriver.compute_crc16(packet(1:7));
            packet(8:9) = typecast(uint16(crc), 'uint8');
            packet(10) = 0x7D;
        end

        function packet = write_f32_request(address, value)
            packet = zeros(1, 14, 'uint8');
            packet(1:3) = [0x7B, LTBusDriver.DEFAULT_SLAVE_ID, LTBusDriver.LT_BUS_WRITE_FC];
            packet(4:5) = typecast(uint16(address), 'uint8');
            packet(6:7) = [4, 0];
            packet(8:11) = typecast(single(value), 'uint8');

            crc = LTBusDriver.compute_crc16(packet(1:11));
            packet(12:13) = typecast(uint16(crc), 'uint8');
            packet(14) = 0x7D;
        end

        function value = decode_f32(packet)
            if packet(3) ~= LTBusDriver.LT_BUS_READ_RESP_FC
                return;
            end

            packet_crc = typecast(uint8(packet(end-2:end-1)), 'uint16');
            expected_crc = LTBusDriver.compute_crc16(packet(1:end - LTBusDriver.LT_BUS_PACKET_FOOTER_SIZE));

            if packet_crc ~= expected_crc
                return;
            end

            if packet(2) ~= LTBusDriver.DEFAULT_SLAVE_ID
                return;
            end

            val_bytes = packet(LTBusDriver.LT_BUS_PACKET_HEADER_SIZE + (1:4));
            value = typecast(uint8(val_bytes), 'single');
        end

        function packet = write_u16_request(address, value)
            packet = zeros(1, 12, 'uint8');
            packet(1:3) = [0x7B, LTBusDriver.DEFAULT_SLAVE_ID, LTBusDriver.LT_BUS_WRITE_FC];
            packet(4:5) = typecast(uint16(address), 'uint8');
            packet(6:7) = [2, 0];
            packet(8:9) = typecast(uint16(value), 'uint8');

            crc = LTBusDriver.compute_crc16(packet(1:9));
            packet(10:11) = typecast(uint16(crc), 'uint8');
            packet(12) = 0x7D;
        end

        function value = decode_u16(packet)
            if packet(3) ~= LTBusDriver.LT_BUS_READ_RESP_FC
                return;
            end

            packet_crc = typecast(uint8(packet(end-2:end-1)), 'uint16');
            expected_crc = LTBusDriver.compute_crc16(packet(1:end - LTBusDriver.LT_BUS_PACKET_FOOTER_SIZE));

            if packet_crc ~= expected_crc
                return;
            end

            if packet(2) ~= LTBusDriver.DEFAULT_SLAVE_ID
                return;
            end

            val_bytes = packet(LTBusDriver.LT_BUS_PACKET_HEADER_SIZE + (1:2));
            value = typecast(uint8(val_bytes), 'uint16');
        end

        function packet = write_i16_request(address, value)
            packet = zeros(1, 12, 'uint8');
            packet(1:3) = [0x7B, LTBusDriver.DEFAULT_SLAVE_ID, LTBusDriver.LT_BUS_WRITE_FC];
            packet(4:5) = typecast(uint16(address), 'uint8');
            packet(6:7) = [2, 0];
            packet(8:9) = typecast(int16(value), 'uint8');

            crc = LTBusDriver.compute_crc16(packet(1:9));
            packet(10:11) = typecast(uint16(crc), 'uint8');
            packet(12) = 0x7D;
        end

        function value = decode_i16(packet)
            if packet(3) ~= LTBusDriver.LT_BUS_READ_RESP_FC
                return;
            end

            packet_crc = typecast(uint8(packet(end-2:end-1)), 'uint16');
            expected_crc = LTBusDriver.compute_crc16(packet(1:end - LTBusDriver.LT_BUS_PACKET_FOOTER_SIZE));

            if packet_crc ~= expected_crc
                return;
            end

            if packet(2) ~= LTBusDriver.DEFAULT_SLAVE_ID
                return;
            end

            val_bytes = packet(LTBusDriver.LT_BUS_PACKET_HEADER_SIZE + (1:2));
            value = typecast(uint8(val_bytes), 'int16');
        end
    end

    methods (Static, Access = private)
        function table = initCRC16Table()
            table = zeros(1, 256, 'uint16');
            for i = 0:255
                crc = uint16(i);
                for j = 1:8
                    if bitand(crc, 1)
                        crc = bitxor(bitshift(crc, -1), 0x8408);
                    else
                        crc = bitshift(crc, -1);
                    end
                end
                table(i + 1) = crc;
            end
        end
    end
end
