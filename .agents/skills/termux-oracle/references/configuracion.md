# Configuración Inicial de Termux

## Actualización del sistema
```bash
pkg update && pkg upgrade -y
```
Durante `dpkg`, presionar `N` para conservar configuraciones locales.

## Cambio de repositorio (mirrors)
```bash
termux-change-repo
```
Seleccionar `Main repository`, `Game repository`, `Science repository`. Mirrors recomendados: **Grimler** o **Albatross**.

## Teclado y Extra Keys
```bash
mkdir -p ~/.termux
cat <<EOT > ~/.termux/termux.properties
extra-keys = [ \\
  ['ESC','/','-','HOME','UP','END','PGUP'], \\
  ['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN'] \\
]
EOT
termux-reload-settings
```

## Personalización visual (Termux:Styling)
Pulsación larga en terminal → More... → Style → Elegir color y fuente.

## Alias útiles (`~/.bashrc`)
```bash
alias ls='ls --color=auto'
alias ll='ls -la'
alias sd='cd /sdcard'
alias update='pkg update && pkg upgrade -y'
```
Recargar: `source ~/.bashrc`
