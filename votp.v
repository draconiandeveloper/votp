module votp

import encoding.binary
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
	HOTP
	expiry	int
}

pub fn new[T](secret string, digits int, expiry int) T {
	$if T is HOTP {
		return T{base32.encode(secret.bytes()), digits}
	}
	$else $if T is TOTP {
		return T{HOTP{base32.encode(secret.bytes()), digits}, expiry}
	}
	$else {
		panic("VOTP can only initialize either HOTP or TOTP!")
	}
}

pub fn generate[T](otp T, counter u64) string {
	mut msg := []u8{len: 8};

	$if T is TOTP {
		timeslice := u64(time.utc().unix() / otp.expiry);
		binary.big_endian_put_u64(mut msg, timeslice);
	}
	$else $if T is HOTP { binary.big_endian_put_u64(mut msg, counter); }
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

pub fn verify[T](otp T, input string, counter u64) bool {
	mut token := T{};

	secret := base32.decode(otp.secret) or { panic(err) }.bytestr();
	$if T is TOTP { token = new[T](secret, otp.digits, otp.expiry); }
	$else $if T is HOTP { token = new[T](secret, otp.digits, 0); }
	$else { panic("VOTP can only verify HOTP or TOTP!") }

	code := generate[T](token, counter);
	padded := '0'.repeat(token.digits - code.len) + code;
	return padded == input
}
