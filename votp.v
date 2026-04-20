module votp

import encoding.base32
import crypto.sha1
import crypto.hmac
import time
import math

pub struct HOTP {
	secret	[]u8
	digits	int
}

pub struct TOTP {
	secret	[]u8
	digits	int
	expiry	int
}

fn u64_to_bytes(number i64) []u8 {
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

pub fn new[T](secret []u8, digits int, expiry int) T {
	$if T is HOTP {
		return T{secret, digits}
	}
	$else $if T is TOTP {
		return T{secret, digits, expiry}
	}
	$else {
		panic("VOTP can only initialize either HOTP or TOTP!")
	}
}

pub fn generate[T](otp T, counter int) string {
	mut msg := []u8{};

	$if T is TOTP {
		timeslice := u64((time.now().unix() - 10800) / otp.expiry);
		msg = u64_to_bytes(timeslice);
	}
	$else $if T is HOTP { msg = u64_to_bytes(counter); }
	$else { panic("VOTP can only generate HOTP or TOTP!") }

	
	key := base32.decode(otp.secret) or { panic(err) };
	hash := hmac.new(key, msg, sha1.sum, sha1.block_size);
	offset := hash.last() & 0xF;

	mut bincode := u32(hash[offset + 0] & 0x7F) << 24;
	    bincode |= u32(hash[offset + 1] & 0xFF) << 16;
		bincode |= u32(hash[offset + 2] & 0xFF) <<  8;
		bincode |= u32(hash[offset + 3] & 0xFF) <<  0;
	
	code := (bincode % math.powi(10, otp.digits)).str();
	return '0'.repeat(otp.digits - code.len) + code
}

pub fn verify[T](otp T, input string, counter int) bool {
	mut token := T{};
	
	$if T is TOTP { token = new[T](otp.secret, otp.digits, otp.expiry); }
	$else $if T is HOTP { token = new[T](otp.secret, otp.digits, 0); }
	$else { panic("VOTP can only verify HOTP or TOTP!") }

	code := generate[T](token, counter);
	padded := '0'.repeat(token.digits - code.len) + code;
	return padded == input
}
