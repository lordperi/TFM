# Manual de Usuario — DiaBeaty

**Versión**: 1.0
**Fecha**: Febrero 2026
**App**: https://diabetics.jljimenez.es
**Soporte**: https://diabetics-api.jljimenez.es/docs

---

> **AVISO LEGAL IMPORTANTE**
> DiaBeaty es una herramienta de apoyo a la gestión de la Diabetes Tipo 1. Los cálculos de dosis de insulina que ofrece la aplicación son sugerencias basadas en los parámetros médicos que usted mismo configura. **Nunca tome decisiones de dosificación de insulina únicamente basándose en esta aplicación sin la supervisión de su equipo médico.** Consulte siempre con su endocrinólogo o educador en diabetes ante cualquier duda.

---

## Tabla de Contenidos

1. [Introducción](#1-introducción)
2. [Registro e Inicio de Sesión](#2-registro-e-inicio-de-sesión)
3. [Gestión de Perfiles Familiares](#3-gestión-de-perfiles-familiares)
4. [Dashboard Principal — Modo Adulto](#4-dashboard-principal--modo-adulto)
5. [Registrar una Medición de Glucosa](#5-registrar-una-medición-de-glucosa)
6. [Motor Nutricional — Cómo Registrar una Comida](#6-motor-nutricional--cómo-registrar-una-comida)
7. [Entender el Cálculo de Bolus](#7-entender-el-cálculo-de-bolus)
8. [Perfil y Configuración Médica](#8-perfil-y-configuración-médica)
9. [Modo Niño — Héroe de la Salud](#9-modo-niño--héroe-de-la-salud)
10. [Preguntas Frecuentes](#10-preguntas-frecuentes)
11. [Advertencia Médica](#11-advertencia-médica)

---

## 1. Introducción

### ¿Qué es DiaBeaty?

DiaBeaty es una aplicación web progresiva (PWA) diseñada específicamente para personas que conviven con la **Diabetes Tipo 1 (T1D)** y sus familias. Actúa como un **páncreas digital auxiliar**: no reemplaza el órgano, pero proporciona la inteligencia de cálculo que el páncreas sano realiza de manera automática.

Cada vez que una persona con diabetes va a comer, debe responder tres preguntas críticas:

1. ¿Cuántos carbohidratos tiene lo que voy a comer?
2. ¿Cuánta insulina necesito para cubrir esos carbohidratos?
3. ¿Mi glucosa actual requiere una corrección adicional?

Responder estas preguntas correctamente, múltiples veces al día, es una carga cognitiva enorme. Un error de cálculo puede provocar una hipoglucemia severa (glucosa demasiado baja) o una hiperglucemia prolongada (glucosa demasiado alta), ambas situaciones potencialmente peligrosas.

**DiaBeaty automatiza este proceso** proporcionando:

- Una base de datos de 181 alimentos con su contenido en carbohidratos e índice glucémico.
- Un calculador de bolus de insulina basado en sus parámetros médicos personales.
- Un historial de glucosa con gráfica de tendencia de 24 horas.
- Un sistema de registro de comidas con desglose nutricional completo.

### Dos Modos de Interfaz

DiaBeaty se adapta al usuario:

**Modo Adulto (Tutor)**: Interfaz técnica y médica con colores azules, pensada para adultos y para padres que gestionan la diabetes de sus hijos. Muestra datos numéricos precisos, gráficas de tendencia y desglose nutricional detallado.

**Modo Niño (Héroe de la Salud)**: Interfaz gamificada con colores vibrantes, iconografía de aventura y un sistema de puntos de experiencia (XP). Convierte las rutinas diarias de gestión de la diabetes en misiones y logros, reduciendo el estrés y mejorando la adherencia en pacientes infantiles.

### ¿Para Quién es Este Manual?

Este manual está dirigido a tres tipos de usuarios:

- **Pacientes adultos** con Diabetes Tipo 1 que gestionan su propia enfermedad.
- **Padres y tutores** de niños y adolescentes con diabetes.
- **Personal médico** (endocrinólogos, educadores en diabetes, enfermeras especializadas) que deseen orientar a sus pacientes en el uso de la herramienta.

---

## 2. Registro e Inicio de Sesión

### 2.1 Crear una Cuenta

Para comenzar a utilizar DiaBeaty, necesita crear una cuenta. Acceda a la aplicación en **https://diabetics.jljimenez.es** desde cualquier navegador moderno (Chrome, Firefox, Safari, Edge).

```
┌─────────────────────────────────────────┐
│           DIABEATY                      │
│      Páncreas Digital Auxiliar          │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │  Correo electrónico               │  │
│  │  [____________________________]   │  │
│  │                                   │  │
│  │  Contraseña                       │  │
│  │  [____________________________]   │  │
│  │                                   │  │
│  │  [       INICIAR SESIÓN       ]   │  │
│  │                                   │  │
│  │  ¿No tienes cuenta? REGISTRARTE   │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

Pulse en **REGISTRARTE** e introduzca los siguientes datos:

| Campo | Descripción | Ejemplo |
|:------|:------------|:--------|
| Nombre completo | Su nombre y apellidos | Ana García López |
| Correo electrónico | Una dirección de email válida | ana@ejemplo.com |
| Contraseña | Mínimo 8 caracteres | (Su contraseña segura) |
| Confirmación de contraseña | Repita la contraseña | (Igual que la anterior) |

Una vez completado el formulario y pulsado **CREAR CUENTA**, será redirigido automáticamente a completar su perfil médico.

### 2.2 Completar el Perfil Médico

Esta es la pantalla más importante del proceso de registro. Los parámetros que introduzca aquí determinan directamente los cálculos de bolus de insulina que la aplicación realizará.

```
┌─────────────────────────────────────────┐
│         PERFIL MÉDICO                   │
│  Configura tus parámetros personales    │
│                                         │
│  Tipo de Diabetes                       │
│  [ Tipo 1  ▼ ]                          │
│                                         │
│  ICR (Ratio Insulina:Carbohidratos)     │
│  Gramos de CHO por unidad de insulina   │
│  [ 10  ] g/U                            │
│                                         │
│  ISF (Factor de Sensibilidad)           │
│  Bajada de glucosa por unidad           │
│  [ 40  ] mg/dL por unidad              │
│                                         │
│  Glucosa Objetivo                       │
│  [ 100 ] mg/dL                          │
│                                         │
│  [        GUARDAR PERFIL          ]     │
└─────────────────────────────────────────┘
```

**Explicación de cada parámetro:**

**ICR (Insulin-to-Carb Ratio — Ratio Insulina-Carbohidrato)**
Este número indica cuántos gramos de carbohidratos cubre una unidad de insulina. Si su ICR es 10, significa que necesita 1 unidad de insulina por cada 10 gramos de carbohidratos que consuma. Este valor es **personal e individual** y debe ser determinado por su médico o educador en diabetes. Los valores típicos oscilan entre 8 y 20 g/U, aunque pueden variar mucho.

**ISF (Insulin Sensitivity Factor — Factor de Sensibilidad a la Insulina)**
Indica cuántos mg/dL baja su glucosa en sangre por cada unidad de insulina que se administre. Si su ISF es 40, una unidad de insulina bajará su glucosa 40 mg/dL. Este valor también es personal. Los valores típicos están entre 20 y 80 mg/dL/U.

**Glucosa Objetivo**
El nivel de glucosa en sangre al que desea llegar después de la corrección. Normalmente se sitúa entre 80 y 120 mg/dL, siendo 100 mg/dL un valor habitual. Su médico le indicará el objetivo más apropiado para su caso.

> **Importante**: Estos valores deben ser proporcionados o validados por su equipo médico. Valores incorrectos producirán cálculos de bolus incorrectos.

Todos los datos médicos se almacenan **cifrados con AES-256** en el servidor. Nadie más que usted puede ver sus parámetros médicos.

### 2.3 Iniciar Sesión

Una vez creada la cuenta, acceda con su correo electrónico y contraseña. La sesión se mantiene activa mediante un token de seguridad (JWT) que se renueva automáticamente. Si la aplicación detecta que su sesión ha caducado, le redirigirá automáticamente a la pantalla de inicio de sesión.

---

## 3. Gestión de Perfiles Familiares

DiaBeaty permite a un **Guardián** (adulto responsable) gestionar múltiples perfiles de **Pacientes Dependientes**. Esto es especialmente útil para padres que administran la diabetes de uno o varios hijos.

### 3.1 Añadir un Perfil de Paciente

Desde el menú principal, acceda a **Perfiles** y pulse el botón **+ Añadir Paciente**.

```
┌─────────────────────────────────────────┐
│           PERFILES FAMILIARES           │
│                                         │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐ │
│  │  Ana G. │  │  Pablo  │  │    +    │ │
│  │  Adulto │  │  8 años │  │ Añadir  │ │
│  │  ●Act.  │  │         │  │         │ │
│  └─────────┘  └─────────┘  └─────────┘ │
│                                         │
│  Perfil activo: Ana García              │
│  [   CAMBIAR PERFIL ACTIVO    ]         │
└─────────────────────────────────────────┘
```

Al crear un perfil de paciente, introduzca:

- **Nombre** del paciente
- **Fecha de nacimiento**
- **Tipo de diabetes** (Tipo 1 por defecto)
- **ICR, ISF y glucosa objetivo** específicos del paciente (los niños suelen tener ratios diferentes a los adultos)
- **PIN de acceso** (opcional, para proteger el perfil)

Cada perfil tiene sus propios parámetros médicos y su propio historial de glucosa y comidas. Los datos de cada perfil son completamente independientes.

### 3.2 Cambiar Entre Perfiles

Pulse sobre el nombre de cualquier perfil en la pantalla de Perfiles para activarlo. El perfil activo queda marcado con un indicador visual. Todos los registros de glucosa y comidas se asociarán al perfil activo en ese momento.

La aplicación cambia automáticamente el tema visual:
- Si el perfil activo es un adulto: interfaz azul, técnica.
- Si el perfil activo es un niño: interfaz colorida, gamificada.

### 3.3 Configurar PIN de Acceso

El PIN protege el perfil de cambios accidentales o accesos no autorizados. Para configurarlo:

1. Seleccione el perfil que desea proteger.
2. Acceda a **Configuración del Perfil**.
3. Active la opción **Proteger con PIN**.
4. Introduzca un PIN de 4 dígitos y confírmelo.

A partir de ese momento, cambiar al perfil o modificar sus datos requerirá introducir el PIN.

---

## 4. Dashboard Principal — Modo Adulto

El Dashboard es la pantalla principal de la aplicación en Modo Adulto. Muestra de un vistazo toda la información relevante para gestionar la diabetes durante el día.

```
┌─────────────────────────────────────────┐
│  DiaBeaty         Ana García    ☰       │
│─────────────────────────────────────────│
│  GLUCOSA ACTUAL                         │
│                                         │
│         126 mg/dL  →                   │
│         [  RANGO OBJETIVO  ]            │
│                                         │
│─────────────────────────────────────────│
│  TENDENCIA 24h                          │
│                                         │
│  200│                    ·              │
│     │          ·   ·  ·                 │
│  140│    ·  ·              ·  ·  ·     │
│     │·                                  │
│   80│                                   │
│    ──────────────────────────────       │
│    06h   10h   14h   18h   22h          │
│                                         │
│─────────────────────────────────────────│
│  HOY                                    │
│  CHO Total: 142 g   Insulina: 14.2 U   │
│─────────────────────────────────────────│
│  [Glucosa] [Nutrición] [Perfil]         │
└─────────────────────────────────────────┘
```

### 4.1 Lectura de Glucosa Actual

La lectura más reciente se muestra de forma prominente en la parte superior. El color del valor indica el estado:

| Color | Rango | Significado |
|:------|:------|:------------|
| Verde | 70–140 mg/dL | Dentro del rango objetivo |
| Naranja | 141–250 mg/dL | Hiperglucemia leve, atención |
| Rojo | > 250 mg/dL o < 70 mg/dL | Fuera de rango, acción recomendada |

La flecha junto al valor indica la tendencia: flecha derecha (estable), flecha arriba (subiendo), flecha abajo (bajando).

### 4.2 Gráfica de Tendencia de 24 Horas

La gráfica muestra la evolución de la glucosa durante las últimas 24 horas. Las líneas horizontales de referencia marcan los límites del rango objetivo (normalmente 70 y 140 mg/dL). Los puntos de color más intenso indican registros con marcador de insulina administrada.

Puede desplazarse horizontalmente por la gráfica para ver períodos anteriores.

### 4.3 Resumen del Día

En la parte inferior del Dashboard aparece el resumen acumulado del día:
- **CHO Total**: Gramos de carbohidratos consumidos durante el día.
- **Insulina Total**: Unidades de insulina bolus administradas.

### 4.4 Navegación Principal

La barra inferior contiene tres secciones:
- **Glucosa**: Acceso al registro de glucosa e historial.
- **Nutrición**: Motor nutricional, registro de comidas.
- **Perfil**: Datos personales y configuración médica.

---

## 5. Registrar una Medición de Glucosa

Registrar las mediciones de glucosa con regularidad es fundamental para que la gráfica de tendencia sea útil y para que el cálculo de bolus incluya la corrección adecuada.

### 5.1 Acceder al Registro

Pulse el icono de **Glucosa** en la barra de navegación inferior y luego pulse **+ Añadir Medición**.

```
┌─────────────────────────────────────────┐
│  REGISTRAR GLUCOSA                      │
│                                         │
│  Valor de glucosa                       │
│  ┌───────────────────────────────────┐  │
│  │        126        mg/dL          │  │
│  └───────────────────────────────────┘  │
│                                         │
│  Tipo de medición                       │
│  ○ Sensor (MCG/CGM)                     │
│  ○ Punción en dedo                      │
│  ○ Introducción manual                  │
│                                         │
│  Notas (opcional)                       │
│  [ Antes del desayuno...           ]    │
│                                         │
│  [         REGISTRAR              ]     │
└─────────────────────────────────────────┘
```

### 5.2 Paso a Paso

1. **Introduzca el valor**: Escriba el valor obtenido de su glucómetro o sensor. La aplicación acepta valores entre 40 y 400 mg/dL.

2. **Seleccione el tipo de medición**:
   - **Sensor (MCG/CGM)**: Lectura proveniente de un sensor de glucosa continuo (FreeStyle Libre, Dexcom, etc.).
   - **Punción en dedo**: Lectura obtenida con glucómetro capilar.
   - **Manual**: Registro retrospectivo de un valor anterior.

3. **Añada una nota** (opcional): Puede añadir contexto como "Antes de desayunar", "Después de ejercicio", "Antes de dormir". Las notas ayudan a interpretar las variaciones en el historial.

4. **Pulse REGISTRAR**: El valor queda guardado inmediatamente y aparece en la gráfica del Dashboard.

### 5.3 Historial de Glucosa

El historial muestra todas las mediciones ordenadas cronológicamente. Puede filtrar por rango de fechas para analizar períodos específicos. El historial es especialmente útil para compartir datos con su médico en las revisiones.

---

## 6. Motor Nutricional — Cómo Registrar una Comida

El motor nutricional es el corazón de DiaBeaty. Permite calcular con precisión la insulina necesaria para cualquier comida, por compleja que sea.

### 6.1 Acceder al Hub Nutricional

Pulse el icono de **Nutrición** en la barra de navegación. Llegará al Hub Nutricional, una pantalla central con cinco secciones:

```
┌─────────────────────────────────────────┐
│  HUB NUTRICIONAL                        │
│─────────────────────────────────────────│
│  RESUMEN DE HOY                         │
│  Carbohidratos: 142 g                   │
│  Carga Glucémica: 89                    │
│  Insulina bolus: 14.2 U                 │
│─────────────────────────────────────────│
│                                         │
│  ┌───────────────────────────────────┐  │
│  │   + REGISTRAR NUEVA COMIDA        │  │
│  │   Calcula tu bolus y registra     │  │
│  └───────────────────────────────────┘  │
│                                         │
│─────────────────────────────────────────│
│  DOSIS RÁPIDA DE INSULINA               │
│  [   Solo corrección (sin comida)  ]    │
│─────────────────────────────────────────│
│  GUÍA DE ÍNDICE GLUCÉMICO               │
│  [   Ver tabla de referencia       ]    │
│─────────────────────────────────────────│
│  COMIDAS RECIENTES                      │
│  Hoy, 14:30  Arroz + Pollo + Ensalada  │
│  Hoy, 08:15  Tostada + Zumo de naranja │
└─────────────────────────────────────────┘
```

### 6.2 Iniciar el Registro de Comida

Pulse el botón **+ REGISTRAR NUEVA COMIDA** para abrir la pantalla de registro (LogMealScreen). Esta pantalla tiene tres áreas principales:

- **Buscador de alimentos** en la parte superior.
- **Bandeja de ingredientes** en el centro (inicialmente vacía).
- **Botón de calcular bolus** en la parte inferior.

### 6.3 Buscar y Añadir Alimentos

```
┌─────────────────────────────────────────┐
│  REGISTRAR COMIDA                       │
│                                         │
│  🔍 Buscar alimento...                  │
│  [ arroz                          ]     │
│                                         │
│  Resultados:                            │
│  ┌─────────────────────────────────┐    │
│  │ Arroz blanco cocido    27g CHO  │ +  │
│  │ Arroz integral cocido  23g CHO  │ +  │
│  │ Arroz con leche        18g CHO  │ +  │
│  └─────────────────────────────────┘    │
│                                         │
│  BANDEJA                                │
│  ┌─────────────────────────────────┐    │
│  │ Arroz blanco  150g  40.5g CHO   │ 🗑 │
│  │ Pollo a la plancha  120g  0g CHO│ 🗑 │
│  └─────────────────────────────────┘    │
│                                         │
│  Total CHO: 40.5 g  CG: 23.4           │
│                                         │
│  [ CALCULAR BOLUS RECOMENDADO ]         │
└─────────────────────────────────────────┘
```

**Pasos para añadir alimentos:**

1. **Escriba el nombre** del alimento en el buscador. La búsqueda es en tiempo real y no requiere pulsar "Buscar". La base de datos contiene 181 ingredientes comunes categorizados (cereales, carnes, frutas, verduras, lácteos, legumbres, etc.).

2. **Seleccione el alimento** de la lista de resultados pulsando el botón **+**.

3. **Ajuste la cantidad**: Aparecerá un diálogo para introducir los gramos. Introduzca la cantidad real que va a consumir. La aplicación calculará automáticamente los carbohidratos proporcionales a la cantidad introducida.

4. **El alimento se añade a la bandeja**. Puede continuar buscando y añadiendo más alimentos sin que la bandeja se vacíe.

5. **Para eliminar un alimento** de la bandeja, pulse el icono de papelera (🗑) junto a él.

### 6.4 Ver el Resumen Nutricional

En la parte inferior de la pantalla, debajo de la bandeja, puede ver en tiempo real:

- **Total CHO**: Gramos totales de carbohidratos de todos los alimentos en la bandeja.
- **Carga Glucémica (CG)**: Un indicador más preciso que los gramos de carbohidratos, ya que tiene en cuenta el índice glucémico de cada alimento. Una CG baja (< 10) indica poco impacto en la glucosa; alta (> 20) indica impacto elevado.

### 6.5 Calcular el Bolus Recomendado

Una vez que haya añadido todos los alimentos, pulse **CALCULAR BOLUS RECOMENDADO**.

La aplicación pedirá su **glucosa actual** (introduzca el valor de su última medición) y calculará la dosis recomendada:

```
┌─────────────────────────────────────────┐
│  RESULTADO DEL BOLUS                    │
│                                         │
│  Glucosa actual:   126 mg/dL            │
│  Glucosa objetivo: 100 mg/dL            │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  Desglose de ingredientes:      │    │
│  │  Arroz blanco (150g): 40.5g CHO │    │
│  │  Bolus CHO:           4.05 U    │    │
│  │  ─────────────────────────────  │    │
│  │  Corrección glucosa:  0.65 U    │    │
│  │  ─────────────────────────────  │    │
│  │  TOTAL RECOMENDADO:   4.7 U     │    │
│  │                                 │    │
│  │  ████████████░░  🟠 MODERADO    │    │
│  └─────────────────────────────────┘    │
│                                         │
│  Dosis administrada: [ 4.7 ] U          │
│                                         │
│  [     CONFIRMAR Y REGISTRAR     ]      │
└─────────────────────────────────────────┘
```

El indicador de color muestra el nivel de la dosis:
- **Verde** (≤ 2 U): Comida ligera, bajo impacto glucémico.
- **Naranja** (2–5 U): Comida moderada, atención recomendada.
- **Rojo** (> 5 U): Comida abundante, revise con su médico si es habitual.

### 6.6 Confirmar y Registrar la Comida

Puede modificar la dosis en el campo **Dosis administrada** si su médico le ha indicado aplicar un ajuste o si ha decidido una dosis diferente. Pulse **CONFIRMAR Y REGISTRAR** para guardar la comida con todos sus datos nutricionales.

La comida queda registrada en el historial y el resumen del día del Hub Nutricional se actualiza automáticamente.

---

## 7. Entender el Cálculo de Bolus

Esta sección es especialmente importante para que comprenda cómo funciona la lógica de cálculo de DiaBeaty y pueda usar la aplicación de forma informada.

### 7.1 ¿Qué es el ICR?

El **ICR (Ratio Insulina-Carbohidrato)** es el número de gramos de carbohidratos que cubre una unidad de insulina rápida. Es un parámetro personal que varía de persona a persona y puede incluso variar a lo largo del día.

**Ejemplo**: Si su ICR es 10 y va a comer 50 gramos de carbohidratos:
```
Bolus por CHO = 50 g ÷ 10 g/U = 5 U de insulina
```

### 7.2 ¿Qué es el ISF?

El **ISF (Factor de Sensibilidad a la Insulina)** indica cuántos mg/dL baja su glucosa en sangre por cada unidad de insulina. Se utiliza para calcular la corrección cuando la glucosa actual no está en el objetivo.

**Ejemplo**: Si su ISF es 40 y su glucosa está en 160 mg/dL con un objetivo de 100 mg/dL:
```
Corrección = (160 - 100) ÷ 40 = 1.5 U de insulina correctora
```

### 7.3 La Fórmula Completa

DiaBeaty aplica la siguiente fórmula reconocida en el ámbito de la diabetología:

```
Bolus Total = (Carbohidratos / ICR) + ((Glucosa Actual - Glucosa Objetivo) / ISF)

Siempre se aplica: Bolus Total = máximo(0, Bolus Total)
```

La última línea garantiza que el resultado nunca sea negativo: si su glucosa ya está por debajo del objetivo, la fórmula nunca sugerirá una dosis negativa (que no tiene sentido clínico).

**Ejemplo completo:**
- Carbohidratos de la comida: 60 g
- ICR: 10 → Bolus CHO = 60/10 = 6 U
- Glucosa actual: 150 mg/dL
- Glucosa objetivo: 100 mg/dL
- ISF: 50 → Corrección = (150-100)/50 = 1 U
- **Bolus Total recomendado: 7 U**

### 7.4 ¿Qué es la Carga Glucémica?

La **Carga Glucémica (CG)** es un indicador más completo que los gramos de carbohidratos porque tiene en cuenta la velocidad con la que cada alimento eleva la glucosa (Índice Glucémico).

```
CG = (Índice Glucémico × Carbohidratos Netos) ÷ 100
```

Un alimento puede tener muchos carbohidratos pero bajo IG (como las lentejas) y por tanto una CG moderada. Otro puede tener pocos carbohidratos pero IG muy alto (como el pan blanco) con una CG elevada.

| Carga Glucémica | Interpretación |
|:----------------|:---------------|
| < 10 | Baja: impacto leve en glucosa |
| 10–20 | Media: impacto moderado |
| > 20 | Alta: impacto elevado, vigilar tendencia |

### 7.5 Cuándo Consultar al Médico

La sugerencia de bolus de DiaBeaty es un punto de partida, no una prescripción. Consulte con su endocrinólogo o educador en diabetes cuando:

- La sugerencia de bolus sea frecuentemente muy diferente a lo que usted necesita en la práctica.
- Experimente hipoglucemias o hiperglucemias repetidas después de seguir la sugerencia.
- Sus necesidades de insulina cambien (por crecimiento, cambio de actividad física, enfermedad, etc.).
- Quiera revisar o ajustar su ICR, ISF o glucosa objetivo.

---

## 8. Perfil y Configuración Médica

### 8.1 Acceder al Perfil

Pulse el icono de **Perfil** en la barra de navegación inferior. Verá su información personal y sus parámetros médicos actuales.

```
┌─────────────────────────────────────────┐
│  MI PERFIL                              │
│                                         │
│  ┌──────┐  Ana García López             │
│  │  AG  │  ana@ejemplo.com              │
│  └──────┘  Diabetes Tipo 1              │
│                                         │
│─────────────────────────────────────────│
│  PARÁMETROS MÉDICOS                     │
│                                         │
│  ICR                          10 g/U   │
│  ISF                          40 mg/U  │
│  Glucosa Objetivo             100 mg/dL│
│                                         │
│  [   EDITAR PARÁMETROS MÉDICOS   ]      │
│                                         │
│─────────────────────────────────────────│
│  CUENTA                                 │
│  [   CAMBIAR CONTRASEÑA          ]      │
│  [   CERRAR SESIÓN               ]      │
└─────────────────────────────────────────┘
```

### 8.2 Actualizar Parámetros Médicos

Pulse **EDITAR PARÁMETROS MÉDICOS** para modificar su ICR, ISF o glucosa objetivo. Estos cambios afectan inmediatamente a los cálculos de bolus. Le recomendamos actualizar estos valores siempre que su médico le indique un ajuste en sus ratios.

Los cambios se guardan de forma cifrada en el servidor. Su historial de comidas y glucosa registrado previamente no se recalcula; los nuevos registros usarán los nuevos parámetros.

### 8.3 Cambiar Contraseña

Para cambiar su contraseña, pulse **CAMBIAR CONTRASEÑA**, introduzca su contraseña actual y luego la nueva contraseña dos veces para confirmarla.

---

## 9. Modo Niño — Héroe de la Salud

El Modo Niño transforma la gestión de la diabetes en una aventura RPG. Cuando el perfil activo es un paciente infantil, la interfaz cambia completamente para ofrecer una experiencia motivadora y divertida.

### 9.1 Cómo Activarlo

El Modo Niño se activa automáticamente cuando se selecciona el perfil de un paciente niño. No requiere ninguna configuración adicional. Si el perfil tiene registrada una fecha de nacimiento que indica menos de 14 años, el modo niño se activa por defecto.

El Guardián (padre o tutor) puede alternar entre la vista de adulto y la vista niño desde la pantalla de perfiles.

### 9.2 La Interfaz del Héroe

```
┌─────────────────────────────────────────┐
│  ⚔️  HÉROE: PABLO                  🏆  │
│─────────────────────────────────────────│
│                                         │
│      ★ GUERRERO NIVEL 5 ★              │
│                                         │
│  XP: ████████████░░░░  420/500         │
│                                         │
│  💧 Glucosa: 118 mg/dL  ✅             │
│                                         │
│─────────────────────────────────────────│
│  MISIONES DE HOY                        │
│  ✅ Registrar glucosa matutina           │
│  ✅ Registrar desayuno                   │
│  ⬜ Registrar comida del mediodía       │
│  ⬜ Registrar glucosa nocturna          │
│─────────────────────────────────────────│
│  🏅 MEDALLAS RECIENTES                  │
│  🔥 Racha de 7 días   🍎 5 comidas hoy  │
│                                         │
│  [ ⚔️  REGISTRAR COMIDA — MISIÓN ]      │
└─────────────────────────────────────────┘
```

### 9.3 Sistema de XP y Niveles

El sistema de puntos de experiencia (XP) premia al niño por realizar acciones positivas de gestión de su diabetes:

| Acción | XP ganado |
|:-------|:---------:|
| Registrar una comida | +10 XP |
| Registrar una medición de glucosa | +5 XP |
| Completar todas las misiones del día | +25 XP |

Los niveles y sus umbrales son:

| Nivel | Nombre | XP requerido |
|:-----:|:-------|:------------:|
| 1–2 | Explorador | 0–99 XP |
| 3–4 | Aventurero | 100–249 XP |
| 5–6 | Guerrero | 250–499 XP |
| 7–8 | Héroe | 500–999 XP |
| 9–10 | Campeón | 1000–1999 XP |
| 11+ | Leyenda | 2000+ XP |

La barra de XP en el Dashboard muestra el progreso hacia el siguiente nivel con una animación que avanza al registrar cada acción.

### 9.4 Medallas y Logros

Las medallas son recompensas especiales por hitos de comportamiento:

| Medalla | Condición |
|:--------|:----------|
| 🔥 Racha Imparable | 7 días consecutivos registrando comidas |
| 🍎 Héroe Nutricional | 5 comidas registradas en un día |
| 💎 Explorador Glucémico | 30 mediciones de glucosa en un mes |
| ⚡ Velocidad Relámpago | Registrar la comida en menos de 2 minutos |
| 🌟 Leyenda de la Salud | Alcanzar el nivel Leyenda |

Las medallas desbloqueadas se muestran en el perfil del héroe y se pueden compartir con los padres.

### 9.5 Registrar Comidas como Misión

En el Modo Niño, el registro de comidas se presenta como una misión épica:

```
┌─────────────────────────────────────────┐
│  ⚔️  ¡NUEVA MISIÓN!                    │
│  "La Poción del Mediodía"               │
│                                         │
│  Tu héroe necesita energía para         │
│  la batalla. ¡Registra tu comida!       │
│                                         │
│  🔍 Buscar ingrediente mágico...        │
│  [ arroz                          ]     │
│                                         │
│  INGREDIENTES EN TU MOCHILA:            │
│  ⚗️ Arroz blanco (150g) — 40 CHO       │
│  🍗 Pollo (120g) — Proteína             │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  ✨ ¡POCIÓN LISTA!              │    │
│  │  Necesitas 4.7 pociones         │    │
│  │  de insulina                    │    │
│  │  ████░░░░░░░  🟠 MODERADO       │    │
│  └─────────────────────────────────┘    │
│                                         │
│  [ ⚔️  ¡COMPLETAR MISIÓN! +10 XP ]     │
└─────────────────────────────────────────┘
```

La funcionalidad es idéntica al Modo Adulto, pero el lenguaje cambia:
- Los alimentos se llaman "ingredientes mágicos".
- La bandeja se llama "mochila del héroe".
- Las unidades de insulina se llaman "pociones de insulina".
- Al completar el registro, aparece una animación de recompensa con el XP ganado.

El niño ve la misma información médica relevante pero presentada de forma lúdica, lo que reduce la ansiedad asociada a la gestión de la diabetes y mejora la adherencia al tratamiento.

---

## 10. Preguntas Frecuentes

**P: ¿Necesito conexión a internet para usar DiaBeaty?**
R: Sí, DiaBeaty es una aplicación web progresiva que requiere conexión a internet para sincronizar datos con el servidor. No funciona en modo offline.

**P: ¿Mis datos médicos están seguros?**
R: Sí. Todos sus parámetros médicos (ICR, ISF, glucosa objetivo) y registros de salud se almacenan cifrados con AES-256 (estándar de cifrado militar) en el servidor. Sus credenciales se protegen con el algoritmo bcrypt. Las comunicaciones siempre se realizan mediante HTTPS.

**P: ¿Puedo usar la aplicación con un sensor de glucosa continuo (MCG)?**
R: Actualmente la aplicación permite registrar manualmente las lecturas de su MCG. La integración directa con sensores (Dexcom, FreeStyle Libre) está planificada para una versión futura.

**P: ¿El bolus calculado por la app incluye la insulina basal?**
R: No. DiaBeaty calcula exclusivamente el **bolus de insulina rápida** (la dosis asociada a la comida y la corrección glucémica). La insulina basal (de acción prolongada o la tasa basal de una bomba) no está contemplada en el cálculo, ya que es una prescripción fija que no varía con cada comida.

**P: ¿Qué pasa si un alimento no está en la base de datos?**
R: La base de datos contiene 181 alimentos comunes. Si un alimento no aparece, puede buscarlo por términos similares (por ejemplo, si busca "pasta al pesto" y no aparece, busque "pasta cocida" como base). En versiones futuras, está previsto añadir reconocimiento por foto y ampliar la base de datos.

**P: ¿Puedo tener más de un guardián por perfil de paciente?**
R: En la versión actual, cada perfil de paciente está asociado a una única cuenta de guardián. El soporte para múltiples guardianes (por ejemplo, dos padres con cuentas separadas) está planificado para versiones futuras.

**P: Mi hijo subió de nivel pero no apareció ninguna animación. ¿Qué ocurrió?**
R: Si la pantalla estaba en segundo plano durante el registro que causó la subida de nivel, puede que la animación no se haya mostrado. La subida de nivel quedó registrada correctamente; puede verificarla en el perfil del héroe.

**P: ¿Puedo exportar mis datos para llevarlos al médico?**
R: La exportación de datos en formato PDF o CSV está planificada para una versión próxima. Por el momento, puede mostrar el historial de glucosa y comidas directamente en la aplicación durante la consulta médica.

**P: ¿La aplicación funciona en el móvil?**
R: Sí. DiaBeaty está desarrollada con Flutter, lo que la hace compatible con navegadores móviles de Android e iOS. Funciona correctamente en smartphones y tabletas.

**P: ¿El modo niño oculta información médica importante?**
R: No. El modo niño presenta la misma información médica relevante (glucosa, CHO, dosis de insulina) pero con un lenguaje adaptado. Los padres siempre tienen acceso a la vista técnica completa cambiando al perfil de adulto.

---

## 11. Advertencia Médica

DiaBeaty es una herramienta de apoyo a la gestión de la Diabetes Tipo 1 desarrollada como proyecto académico. **No es un dispositivo médico certificado.**

Los cálculos de bolus de insulina proporcionados por esta aplicación son sugerencias matemáticas basadas en los parámetros que usted introduce. Su precisión depende directamente de la exactitud de los parámetros médicos configurados (ICR, ISF y glucosa objetivo) y de los alimentos registrados.

**La aplicación no sustituye en ningún caso:**

- El criterio de su médico endocrinólogo o educador en diabetes.
- Las indicaciones de su equipo médico habitual.
- Las guías clínicas de manejo de la Diabetes Tipo 1.
- Los protocolos de actuación ante hipoglucemia o cetoacidosis diabética.

**Ante cualquiera de las siguientes situaciones, busque atención médica inmediata:**

- Glucosa inferior a 70 mg/dL con síntomas (temblor, sudoración, confusión).
- Glucosa superior a 300 mg/dL persistente.
- Presencia de cuerpos cetónicos en orina o sangre.
- Náuseas, vómitos o dolor abdominal en contexto de hiperglucemia.
- Cualquier duda sobre la dosis correcta de insulina a administrar.

El equipo de desarrollo de DiaBeaty no asume ninguna responsabilidad por decisiones clínicas tomadas basándose exclusivamente en los datos o sugerencias proporcionadas por esta aplicación.

---

*Manual de Usuario DiaBeaty v1.0 — Febrero 2026*
*App: https://diabetics.jljimenez.es | API Docs: https://diabetics-api.jljimenez.es/docs*
