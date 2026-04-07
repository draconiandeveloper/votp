module votp

import crypto.sha512
import crypto.hmac

pub fn u64_to_bytes(number i64) []u8 {
	mut bytes := []u8{len: 8};
	mut nn := number;
	mut iter := 7;

	for iter >= 0 {
		bytes[iter] = u8(nn & 0xFF);
		nn >>= 8;
		iter--;
	}

	return bytes
}

pub fn get_hash(message []u8, key []u8) []u8 {
	return hmac.new(key, message, sha512.sum512, sha512.block_size)
}

