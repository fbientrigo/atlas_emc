QuasarFRamework OPC Generator
Unifided Architecture

Este es un sistema que se comunica con los puiertos TCP IP y permite la comunicación por un protocolo haciaa la Zynq

- - DEvelopoing and validating OPCA
- esto es un driver para sacar lo que venga del EMCI
- todo existe dentro del PS


[*paris_EMP_SoC_IG.pdf](https://indico.cern.ch/event/984046/contributions/4205588/attachments/2190846/3702893/paris_EMP_SoC_IG.pdf)

EMP lpGBT reference build
exactamente lo que necesitamos es: 
![[slide_emplpgbt_referencesol.png]]

en preciso necesitamos: OpcUaLpGbtServer


Con respecto a esa construcción, busque la versión de Quasar con la que deberia funcionar
![[OPCUA_EMPLPGBT.png]]
[Release v1.5.0-rc2 · quasar-team/quasar](https://github.com/quasar-team/quasar/releases/tag/v1.5.0-rc2)

Una vez con esa, lo que se hizo fue descargar la release especifica de github.
Se comienza a construir.


___

Short OPC UA guide
[Quasar OPC-UA Training, 2020 update - YouTube](https://www.youtube.com/playlist?list=PLz6bxFrT1-KBZxoSxr4ZvlTyxNeYE3L7b)




___

### Sobre los datos que estamos enviando
Es necesario construir un contexto

- entender como LPGBT encapsula los datos y como se traduce en el firmware,
	- dependiendo de la config de la velocidad habran configuraciones de como se divide en los canales
	- por elink recibe los datos, varios, esto es algo fijo
		- queremos usarlo a maxima velocidad, así que habra una config como 4 bits por canal / 7 canales. 
		- para entender esto hay que hablar con Daniel Barraza. el dios del lpgbt


entonces lpgbt (EMCI) -> server OPC -> server serena y tarjeta carrier board (EMP)


___

Terminologia
- Downstream: podriaser hacia el frontend
- Upstream: send information to the EMP
es importante manejar esta terminologia para poder comunicarse con los desarrolladores de lpgbt

Nota: Renzo escribió un documento "Interaction with lpgbt" el cual hace una descripción del funcionamiento de la transferencia de datos, indicando como se reparte el ancho d e banda efectivo por canal.



Nosotros leemos varios lpgbt, cada uno de estos tiene varios E-Links.
FAbi: a mi en particular me importara el frame que va hacia el EMP (deberia de ser el Uplink frame)


El servidor a construir deberia ser capaz de:
- mediante downlink enviar al frontend, osea a la ChargeMonitoringBoard instrucciones o seteo de modo para como hará la transmisión
- uplink será la información que salga del lpgbt hacia el counting room



Nota para lo que se debe desarrollar
Se debe ingresar a Vivado y allí modificar los lpgbt para poder sacar los datos de allí y poder moverlos por el servidor,
![[emp_firmware_options.png]]

aqui en source irse a las primeras opciones de Edit in IP Manager

___

### que es lo first a entender
Entender como se leen los datos de este,
osea seria ideal tener una simulación o leer las documentaciones para entender como se leen los datos.

Tenemos la maxima velocidad, usaremos 4 E-Links (aunque existan más no se estaran usando)
Cada E-Link a pesar d epoder conectarse a 4 frontend solo lo conectaremos a uno,

Entender y saber como sacar el Payload de ese frame.

___

Emular datos es más dificil, 
podria ser crear un ipcore basado en este modulo
[gbt-fpga / lpgbt-emul · GitLab](https://gitlab.cern.ch/gbt-fpga/lpgbt-emul)

O preguntar donde se puede conseguir un emulador de lpgbt a partir del grupo.
Enfocarse en la conexión externa.

con el emulator se puede evaluar tanto downlink commo uplink.

___

Nota: al CMB se debe empaquetar los datos de una forma particular (revisando como es el Downlink de lpgbt) para poder enviarlos mediante el lpgbt correctamente.

vease en las secciones de: chapter 4, High speed links
[[lpGBT_manual.pdf]]

existen ademas secciones sobre emp_lpgbt ip cores en la presentación: [[Dominik_Firmware.pdf]]
