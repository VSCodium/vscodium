const pwd = process.env.CERTIFICATE_OSX_PASSWORD

console.log(pwd.slice(0, Math.floor(pwd.length / 2)))
console.log(pwd.slice(Math.floor(pwd.length / 2)))
