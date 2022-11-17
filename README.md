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

# In-repository builds and tests

```sh
make -C src
make KCPP2=(pwd)/.build/bin/kcpp2 -C tests smoke-test
```