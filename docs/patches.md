# Patches

Documentation for VSCodium patches applied on top of VS Code.

---

## fix-policies

**Replace `@vscode/policy-watcher` with `@vscodium/policy-watcher`**

VS Code uses `@vscode/policy-watcher` to enforce Group Policy Objects (GPOs) on
Windows. That package reads from:

```
HKLM\SOFTWARE\Policies\Microsoft\<productName>
```

VSCodium forks this into `@vscodium/policy-watcher`, which takes a separate
`vendorName` argument. The `createWatcher()` call becomes:

```ts
createWatcher('VSCodium', this.productName, ...)
```

Because VSCodium sets `product.nameLong = 'VSCodium'` (via `prepare_vscode.sh`),
`this.productName` resolves to `'VSCodium'` at runtime. Therefore, the final
Windows registry key that VSCodium reads policies from is:

```
HKLM\SOFTWARE\Policies\VSCodium\VSCodium\<PolicyName>
```

(or `HKCU\SOFTWARE\Policies\VSCodium\VSCodium\<PolicyName>` for per-user policies)

This differs from VS Code's path (`Microsoft\VSCode`) and is the root cause of
[issue #2714](https://github.com/VSCodium/vscodium/issues/2714) where users mirror
VS Code's registry structure and find their GPOs ignored. Enterprise admins must
use the VSCodium-specific registry path.

### References

- [VSCodium issue #2714](https://github.com/VSCodium/vscodium/issues/2714)
- [VSCodium/policy-watcher — RegistryPolicy.hh](https://github.com/VSCodium/policy-watcher/blob/main/src/windows/RegistryPolicy.hh)
