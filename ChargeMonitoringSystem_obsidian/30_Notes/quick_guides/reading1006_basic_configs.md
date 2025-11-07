Tras cargar el programa

Configurar el reloj
```bash
sudo busybox devmem 0xA00E002C 32 0x00000002
```

Escribir en los registros
```
sudo busybox devmem 0xA00D000C 32 0xAAAAAAAA
sudo busybox devmem 0xA00D000C 32 0x00000000
sudo busybox devmem 0xA00D000C 32 0xAEAEAEAE
```

