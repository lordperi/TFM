# ADR-005: Cifrado de Datos de Salud (PHI)

| Metadatos | Valor |
| :--- | :--- |
| **Fecha** | 2026-02-01 |
| **Estado** | Aceptado |
| **Decisores** | DevSecOps, DPO (Simulado) |

## Contexto

La normativa GDPR y los principios éticos médicos exigen proteger la información de salud personal (PHI). El cifrado en reposo a nivel de disco (TDE) o volumen Docker no protege contra ataques de superusuario, dumps de memoria o inyección SQL que lea la base de datos viva.

## Decisión

Implementar **Application-Level Encryption (ALE)** utilizando cifrado simétrico (AES-128-CBC + HMAC vía Fernet) para columnas sensibles.

* **Columnas Afectadas**: `insulin_sensitivity`, `carb_ratio`, `notes` (y futuros valores de glucosa).
* **Gestión**: El cifrado/descifrado ocurre en el código Python justo antes de persistir/leer. La DB solo ve bytes aleatorios (`blob`).

## Consecuencias

* **Positivas**:
  * **Zero-Trust DB**: El administrador de la base de datos NO puede leer los datos médicos.
  * **Mitigación de Fugas**: Un dump SQL filtrado es inútil sin la clave de aplicación.
* **Negativas**:
  * **Pérdida de Query**: No se pueden hacer consultas SQL directas como `SELECT * WHERE glucose > 120`. (Solución: Filtrado en aplicación o indexado homomórfico futuro).
  * **Gestión de Claves**: La pérdida de la `ENCRYPTION_KEY` implica pérdida irrecuperable de datos.
