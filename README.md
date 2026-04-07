# V OTP 0.2

votp enables you to add TOTP or HOTP functionaltiies in your code [the V programming language](https://vlang.io).

[![Twitter URL](https://img.shields.io/twitter/url.svg?label=Follow%20odai_alghamdi&style=social&url=https%3A%2F%2Ftwitter.com%2Fodai_alghamdi)](https://twitter.com/odai_alghamdi)

## Installation

```
v up
v install OdaiGH.votp
```

## Usage
Time-based one-time password is as follows

```v ignore
import readline { read_line }
import encoding.base32
import odaigh.votp

// You can use a key length of 6 or 8. Anything more or less or in-between might not work correctly on some apps.
const keylen := 6;

// TOTP is time-based, so this serves as our token expiration which is usually 30 or 60 seconds after generating.
// You can add a few seconds of buffer room for network latency, but this code does not implement a buffer (yet).
const interval_in_seconds := 30;

// Encode our secret key in Base32 (generate a new secret key per user otherwise everyone will have the exact same TOTP token!)
key := base32.encode(string("YOUR_SECRET").bytes());

// Initialize the TOTP structure. I decided to default to SHA512 for the digest.
totp := votp.new_totp(key, keylen, interval_in_seconds);

// Generate the TOTP token string.
generated_otp := totp.generate_totp();

// Verify that the TOTP token is valid.
user_input := read_line("Enter the token: ")!;

if totp.verify(user_input) {
	println("TOTP token successfully verified!");
} else {
	println("TOTP token failed to verify!");
}
```

HMAC-based one-time password is as follows

```v ignore
import readline { read_line }
import encoding.base32
import odaigh.votp

// You can use a key length of 6 or 8. Anything more or less or in-between might not work correctly on some apps.
const keylen := 6;

// HOTP relies on a counter, this is usually incremented after each successful HOTP authentication
//  though the RFC 4226 specifications recommend a look-ahead to calculate multiple HOTP tokens in case of
//  network desynchronization. This code does not follow this recommendation (yet).
mut counter := 0;

// Encode our secret key in Base32 (generate a new secret key per user otherwise everyone will have the same exact HOTP token!)
key := base32.encode(string("YOUR_SECRET").bytes());

// Initialize the HOTP structure. I decided to default to SHA512 for the digest.
hotp := votp.new_hotp(key, keylen);

// Generate the HOTP token string.
generated_otp := hotp.generate_hotp(counter);

// Verify that the HOTP token is valid.
user_input := read_line("Enter the token: ")!;

if hotp.verify(user_input, counter) {
	println("HOTP token successfully verified!");
	counter++;
} else {
	println("HOTP token failed to verify!");
}
```

### License
V otp is licensed under MIT.

### Contributing
Follow the instructions in [CONTRIBUTING.md](https://github.com/OdaiGH/votp/blob/master/CONTRIBUTING.md)
