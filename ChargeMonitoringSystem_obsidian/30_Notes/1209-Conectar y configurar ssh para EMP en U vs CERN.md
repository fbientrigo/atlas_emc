# Guía rápida de red y SSH para el EMP (AlmaLinux 9.4)

> Objetivo: poder usar el EMP tanto en la **red de la universidad** como en la **red del CERN**, cambiando de perfil de red de forma limpia y conectándome por SSH desde otro equipo.

---

## 1. Contexto del sistema

- Sistema: AlmaLinux 9.4 (el9, RHEL-like)
- Gestor de red: NetworkManager (`nmcli`)
- Interfaz cableada principal: `eth0`
- Perfiles de red configurados:
  - `university-net` → para la red de la universidad (DHCP)
  - `cern-net` → para la red del CERN (IP estática o lo que se defina allí)
- Servicio SSH: `sshd` (OpenSSH server)

---

## 2. Ver el estado actual de la red

Para ver qué conexión está activa y en qué estado está `eth0`:

```bash
nmcli device status
````

Para ver más detalles de la interfaz:

```bash
nmcli device show eth0
```

Para listar todas las conexiones conocidas:

```bash
nmcli connection show
```

---

## 3. Uso en la universidad

### 3.1 Activar el perfil de red de la universidad

El perfil está pensado para usar **DHCP** (la red de la U da IP automáticamente).

Activar:

```bash
sudo nmcli connection up university-net
```

Comprobar IP asignada:

```bash
ip a
```

Debería aparecer una IP en `eth0` perteneciente a la red de la universidad  
(ejemplo típico: `10.x.x.x`, `172.x.x.x` o `192.168.x.x`).

---

### 3.2 Verificar conectividad

Probar conexión a internet (o a un host interno, según la política de la red):

```bash
ping -c 4 8.8.8.8
ping -c 4 www.google.com
```

Si responde, la red está OK.

---

## 4. Uso en el CERN

### 4.1 Activar el perfil de red del CERN

El perfil `cern-net` está pensado para guardar la configuración **estática** del CERN  
(ejemplo: IP 10.3.84.12/24, gateway 10.3.84.1, DNS del CERN, etc.).

Activar:

```bash
sudo nmcli connection up cern-net
```

Ver IP:

```bash
ip a
```

Comprobar conectividad dentro de la red CERN (por ejemplo, un gateway o servidor conocido):

```bash
ping -c 4 10.3.84.1
```

> Nota: si cambian los parámetros de red en el CERN (nueva IP, gateway, DNS),  
> editar el perfil:

```bash
sudo nmcli connection modify cern-net \
  ipv4.method manual \
  ipv4.addresses "NUEVA_IP/24" \
  ipv4.gateway "NUEVO_GATEWAY" \
  ipv4.dns "DNS1 DNS2"
```

---

## 5. Servicio SSH en el EMP

### 5.1 Instalar (si fuera necesario)

En AlmaLinux:

```bash
sudo dnf install -y openssh-server
```

### 5.2 Habilitar y arrancar `sshd`

```bash
sudo systemctl enable --now sshd
```

Comprobar estado:

```bash
sudo systemctl status sshd
```

Debería aparecer como `active (running)`.

### 5.3 (Opcional) Abrir puerto 22 en el firewall

Si el firewall está activo:

```bash
sudo firewall-cmd --add-service=ssh --permanent
sudo firewall-cmd --reload
```

---

## 6. Conectarse por SSH desde otro equipo

### 6.1 Obtener la IP del EMP

En el EMP:

```bash
ip a
```

Buscar la IP IPv4 asociada a `eth0`:

- En la universidad → IP del rango de la red de la U.
    
- En el CERN → IP del rango CERN (por ej. 10.3.84.12).
    

### 6.2 Conexión SSH desde otro equipo (Linux/macOS/WSL)

```bash
ssh <usuario_en_EMP>@<IP_DEL_EMP>
```

Ejemplo:

```bash
ssh tgc_cms@192.168.1.50
```

### 6.3 Conexión SSH desde Windows (PowerShell o cmd)

En PowerShell/cmd:

```powershell
ssh <usuario_en_EMP>@<IP_DEL_EMP>
```

---

## 7. Flujo típico de uso

### 7.1 En la universidad

En el EMP (localmente):

```bash
sudo nmcli connection up university-net
ip a   # anotar IP
```

En el portátil / PC externo:

```bash
ssh <usuario_en_EMP>@<IP_UNIVERSIDAD>
```

---

### 7.2 En el CERN

En el EMP:

```bash
sudo nmcli connection up cern-net
ip a   # anotar IP CERN
```

En un equipo dentro de la red CERN (o vía VPN CERN):

```bash
ssh <usuario_en_EMP>@<IP_CERN>
```

---

## 8. Troubleshooting rápido

- **No obtengo IP en la universidad con `university-net`:**
    
    - Ver `nmcli device show eth0` y `ip a`.
        
    - Confirmar que el puerto físico está activo (cable, switch, etc.).
        
    - Preguntar al área de redes si el puerto necesita activación / MAC registrada.
        
- **No puedo conectar por SSH pero puedo hacer ping:**
    
    - Revisar servicio:
        
        ```bash
        sudo systemctl status sshd
        ```
        
    - Revisar firewall:
        
        ```bash
        sudo firewall-cmd --list-services
        ```
        
        Debe aparecer `ssh`.
        
- **No puedo hacer ping desde otro equipo:**
    
    - Comprobar si están en la misma subred o si la red bloquea ICMP.
        
    - Probar conexión SSH directamente (a veces ping está bloqueado, pero SSH no).
        

---

## 9. Comandos de referencia rápida

```bash
# Ver conexiones y dispositivos
nmcli device status
nmcli connection show

# Activar perfil universidad
sudo nmcli connection up university-net

# Activar perfil CERN
sudo nmcli connection up cern-net

# Ver IPs
ip a

# Estado de sshd
sudo systemctl status sshd

# Conectarse desde otro equipo
ssh <user>@<IP>
```