# V OTP 0.3

votp enables you to add TOTP or HOTP functionaltiies in your code [the V programming language](https://vlang.io).

[![Twitter URL](https://img.shields.io/twitter/url.svg?label=Follow%20odai_alghamdi&style=social&url=https%3A%2F%2Ftwitter.com%2Fodai_alghamdi)](https://twitter.com/odai_alghamdi)

## Installation

```
v up
v install OdaiGH.votp
```

## Usage

```v ignore
import odaigh.votp { HOTP, TOTP }
import readline { read_line }

// You can use a key length of 6 or 8. Anything more or less or in-between might not work correctly on some apps.
const keylen := 6;

// TOTP is time-based, so this serves as our token expiration which is usually 30 or 60 seconds after generating.
// You can add a few seconds of buffer room for network latency, but this code does not implement a buffer (yet).
const interval_in_seconds := 30;

// You can now set a string as your secret key, you must not re-use this key for multiple users because otherwise
// there will be duplicate tokens generated which defeats the security aspect of HOTP and TOTP.
const secret_key := "YOUR_SECRET";

// If we're using HOTP, then we have a counter variable that increments upon each *successful* token entry.
mut counter := 0;

// Initialize the HOTP or TOTP structure, I opted to change from SHA512 to SHA1 to match the RFCs for HOTP and TOTP.
totp := votp.new[TOTP](secret_key, keylen, interval_in_seconds);
hotp := votp.new[HOTP](secret_key, keylen, interval_in_seconds);

// Generate the HOTP or TOTP token string.
totp_token := votp.generate[TOTP](totp, counter);
hotp_token := votp.generate[HOTP](hotp, counter);

// Verify that the HOTP or TOTP token is valid.
totp_input := read_line("Enter ${totp_token}: ") or { exit(1) };
hotp_input := read_line("Enter ${hotp_token}: ") or { exit(1) };

if votp.verify[TOTP](totp, totp_input, counter) {
	println("TOTP token successfully verified!");
} else {
	println("TOTP token failed to verify!");
}

if votp.verify[HOTP](hotp, hotp_input, counter) {
	println("HOTP token successfully verified!");
	counter++; // Increment upon success
} else {
	println("HOTP token failed to verify!");
}
```

### Using this with authenticator apps.

Authenticator apps will require a URI that follows the following format:

```
TOTP:

otpauth://totp/{app name}?secret={URL safe base32 secret key}&issuer={app name}&algorithm=SHA512&digits={keylen}&period={interval_in_seconds}

HOTP:

otpauth://hotp/{app name}?secret={URL safe base32 secret key}&issuer={app name}&algorithm=SHA512&digits={keylen}&counter={counter}
```

You can generate a QR Code with this URI and that can be scanned in by most authenticator applications to test out your HOTP and TOTP implementation in real-time on real hardware with real-world latencies. It is recommended to experiment with artificial network throttling to determine how the authorization behaves in various network conditions.

### Todo

- [ ] Add a buffer for TOTP token verification.
- [ ] Refactor code to match RFCs for HOTP and TOTP.
- [x] Test the results of HOTP and TOTP tokens on a physical device.

### License
V otp is licensed under MIT.

### Contributing
Follow the instructions in [CONTRIBUTING.md](https://github.com/OdaiGH/votp/blob/master/CONTRIBUTING.md)
