# cpp2-semantics
Towards a formal semantics of CPP2


# Building and testing with Nix

## Building
```sh
nix build -L .
```

## Testing
```sh
nix shell --command make -C tests smoke-test
```
