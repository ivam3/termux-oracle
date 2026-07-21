# fixer: Automatización de Diagnóstico y Reparación

Wrapper central de reparación para Termux + i-HakLab.

## Ejecución
```bash
fixer <comando>
```

## Comandos disponibles
| Comando | Acción |
|---------|--------|
| `apt` | Repara dpkg, resuelve bloqueos, corrige repositorios |
| `burpsuite` | Instala openjdk-21-preinst y configura BurpSuite |
| `downgradeRepo` | Degrada repositorios a versiones legacy |
| `gemini-cli` | Reconstruye `node-pty` vía compilación NDK |
| `localtunnel` | Corrige `Unsupported platform: android` |
| `mariadb` | Soluciona `access denied` inyectando password root |
| `metasploit` | Instala Ruby 2.7.2 aislado para MSF |
| `neovim` | Parchea bufferline.nvim (error E5108) |
| `ngrok` | Corrige `bad address` vía termux-chroot |
| `nrauf` | Remapea archivos Unicode a ASCII post-descompilación |
| `PyMiR` | Sub-solucionador de módulos Python |
| `RuGiR` | Sub-solucionador de gemas Ruby |

## PyMiR (Python Module Repair)

```bash
fixer PyMiR -t <TIPO> -p <2|3> -m <módulo1 módulo2 ...>
```

### Modos de compilación (`-t`)
| Modo | Descripción | Detalle |
|------|-------------|---------|
| `BASIC` | Instalación directa | pandas: CFLAGS + Cython + apt precompilado. pyzmq: `--libzmq`. Auto-remueve rust post-instalación |
| `BLAS` | OpenBLAS del sistema | Exporta `BLAS`, `LAPACK`, `CC=clang` |
| `CYTHON` | Traducción intermedia a C | Instala Cython, exporta `MATHLIB="m"` |
| `LDFLAGS` | Linker del sistema | `-L/system/lib/ -lm -lcompiler_rt`, `--disable-jpeg` |
| `RUST` | Compilador Rust temporal | Instala rust, exporta `RUSTFLAGS` + `CARGO_BUILD_TARGET`, remueve rust+cargo al finalizar |
| `SODIUM` | Sodium decryptor | `SODIUM_INSTALL=system`, `--no-binary :all:` |
| `SOURCE-CODE` | Código fuente PyPI | Descarga .zip, `termux-fix-shebang` recursivo, `python setup.py install` |

### Módulos auto-detectados (instalación vía apt)
`apsw`, `apt`, `bcrypt`, `contourpy`, `cryptography`, `numpy`, `pillow`, `tkinter`, `tldp`, `xcbgen`, `opencv`, `scipy`, `electrum`, `asciinema`, `matplotlib`, `pandas`

### Módulos especiales
- **turtle**: descarga tar.gz, sed patch Python 2→3, `pip install -e`
- **jupyter**: parchea `_sysconfigdata.py` (elimina `-fno-openmp-implicit-rpath`), patchelf en `_zmq.cpython-311.so`, purga rust

### Ejemplos
```bash
fixer PyMiR -t BASIC -p 3 -m pandas
fixer PyMiR -t BLAS -p 3 -m numpy
fixer PyMiR -t RUST -p 3 -m cryptography
fixer PyMiR -t BASIC -p 3 -m jupyter
```

## RuGiR (Ruby Gem Repair)

```bash
fixer RuGiR  # menú interactivo con 7 opciones
```

### Menú de opciones

| Opción | Error | Solución |
|--------|-------|----------|
| 1 | `CANNOT LINK EXECUTABLE "ruby"` (bigdecimal) | Regenera `msfconsole` con `LD_PRELOAD` a bigdecimal.so + auto-arranque PostgreSQL (`initdb`, `pg_ctl`, `createuser msf`, `createdb msf_database`) |
| 2 | Error al parsear Gemfile | `pkg clean && autoclean && autoremove && update --fix-missing && configure -a && upgrade && install clang` |
| 3 | `Could not find <gem>` | Instala gema con `--using-system-libraries`, `bundle config`, genera `Gemfile.local`, elimina `rbnacl` de `Gemfile.lock`, `bundle install --full-index` |
| 4 | libxslt version mismatch | `gem pristine <gema>` (vía bundler o gem directo) |
| 5 | BigDecimal architecture incompatible | Ejecuta script remoto `fixbigdecimal` |
| 6 | `You have already activated bundler X, but your Gemfile requires Y` | `gem install bundler:<new>`, remueve gemspec de versión antigua |
| 7 | `OpenSSL::Cipher::CipherError` | Parchea `hrr_rb_ssh-0.4.2`: sed a `functionable.rb` (líneas 13-15) y `ecdsa_sha2_nistp*.rb` (línea 14) |

### Ejemplos
```bash
fixer RuGiR → opción 1   # reparar msfconsole + PostgreSQL
fixer RuGiR → opción 3   # instalar nokogiri con soporte nativo
fixer RuGiR → opción 7   # corregir OpenSSL en hrr_rb_ssh
```
