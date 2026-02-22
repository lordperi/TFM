# ADR-014: Modo Niño Gamificado — Interfaz RPG "Héroe de la Salud"

| Metadatos | Valor |
| :--- | :--- |
| **Fecha** | 2026-02-22 |
| **Estado** | Aceptado |
| **Decisores** | Lead Architect, Code Specialists, UX Designer |
| **Relacionado con** | ADR-003 (Flutter Frontend), ADR-002 (Clean Architecture) |

---

## Contexto

La Diabetes Tipo 1 en edad pediátrica presenta un desafío clínico y psicológico que va más allá de los aspectos puramente metabólicos. Los niños y adolescentes con T1D deben realizar múltiples mediciones de glucosa al día, calcular carbohidratos en cada comida y administrarse insulina, todo ello en entornos sociales (colegio, cumpleaños, excursiones) donde estas rutinas pueden generarles vergüenza y rechazo. La literatura clínica documenta de forma consistente que la fatiga de manejo y la baja adherencia al tratamiento son problemas prevalentes en pacientes pediátricos.

El sistema DiaBeaty en su versión inicial (ADR-003) contemplaba ya una "Dual UX" mediante `ThemeBloc`, que cambiaba los colores y el lenguaje de la interfaz según el tipo de perfil activo. Sin embargo, el cambio cosmético resultaba insuficiente: una interfaz meramente "más colorida" no aborda la raíz del problema de adherencia. Los estudios sobre gamificación terapéutica en enfermedades crónicas (diabetes, asma, oncología pediátrica) demuestran que los sistemas de recompensa intrínseca basados en mecánicas de juego de rol (RPG) aumentan significativamente la frecuencia y consistencia de las acciones de autocuidado.

A partir de estas evidencias, se identificó la necesidad de implementar un modo de interfaz cualitativamente diferente para perfiles pediátricos, no una variación visual, sino una recontextualización narrativa completa del flujo clínico.

---

## Decisión

Se decide implementar el **Modo Niño "Héroe de la Salud"** como una capa de presentación alternativa completa dentro de la arquitectura Clean Architecture existente, activada automáticamente por `ThemeBloc` cuando el perfil activo corresponde a un paciente pediátrico.

### 1. Principio de diseño: recontextualización narrativa

Cada acción clínica se mapea a un equivalente de temática RPG medieval-fantástica:

| Acción clínica | Equivalente RPG |
| :--- | :--- |
| Registrar una comida | Completar una misión: "La Poción del Mediodía" |
| Buscar alimentos | Explorar el inventario de ingredientes mágicos |
| Bandeja de ingredientes | Mochila del héroe |
| Dosis de insulina | Pociones de insulina |
| Glucosa en rango | Escudo de protección activo |
| Glucosa fuera de rango | Alerta de peligro para el héroe |

La información médica subyacente no se oculta ni se altera: las unidades, los valores de glucosa y los gramos de carbohidratos son los mismos. Solo cambia el marco narrativo.

### 2. Sistema de XP y niveles

Se implementa un sistema de puntos de experiencia (XP) persistente en el backend, asociado al perfil del paciente.

**Acciones recompensadas:**

| Acción | XP otorgado |
| :--- | :---: |
| Registrar una comida (POST /meals) | +10 XP |
| Registrar una medición de glucosa | +5 XP |
| Completar todas las misiones del día | +25 XP (bonus) |

**Escala de niveles:**

| Nivel | Título | Umbral de XP |
| :---: | :--- | :---: |
| 1–2 | Explorador | 0 – 99 |
| 3–4 | Aventurero | 100 – 249 |
| 5–6 | Guerrero | 250 – 499 |
| 7–8 | Héroe | 500 – 999 |
| 9–10 | Campeón | 1.000 – 1.999 |
| 11+ | Leyenda | 2.000+ |

Los umbrales se diseñan de forma que el paso de Explorador a Aventurero (100 XP) sea alcanzable en las primeras dos semanas de uso con adherencia moderada, para garantizar una primera recompensa tangible que refuerce el comportamiento.

### 3. Sistema de medallas y logros

Se implementa un catálogo de medallas desbloqueables asociadas a hitos de comportamiento cuantificables:

| Medalla | Condición de desbloqueo |
| :--- | :--- |
| Racha Imparable | 7 días consecutivos registrando al menos una comida |
| Héroe Nutricional | 5 comidas registradas en un mismo día |
| Explorador Glucémico | 30 mediciones de glucosa en un mes natural |
| Velocidad Relámpago | Completar el flujo de registro en menos de 120 segundos |
| Leyenda de la Salud | Alcanzar el nivel Leyenda (2.000+ XP acumulados) |

Las medallas se almacenan en el backend como un array JSON en el modelo de perfil. El frontend las renderiza en la pantalla de perfil del héroe con una animación de aparición en el momento del desbloqueo.

### 4. Componente `XpProgressBar` en el Dashboard niño

El Dashboard pediátrico sustituye los indicadores técnicos del Dashboard adulto por los siguientes elementos:

- **Cabecera**: Nombre del héroe, nivel actual y título (ej. "⚔️ Pablo — Guerrero Nivel 5").
- **Barra de XP real**: Widget `XpProgressBar` que muestra el progreso hacia el siguiente nivel con animación de llenado. Los datos provienen del `ProfileBloc`.
- **Panel de misiones del día**: Lista de tareas diarias (registrar glucosa matutina, registrar comidas, registrar glucosa nocturna) con estado de completitud.
- **Galería de medallas recientes**: Muestra las últimas 3 medallas desbloqueadas.

### 5. Solución a la race condition en ProfileBloc: carga paralela con `concurrent_transformer`

Durante el desarrollo del Dashboard niño, se identificó una race condition crítica: el `ProfileBloc` necesitaba cargar simultáneamente los datos del perfil médico y los datos de XP/nivel del mismo paciente. La secuencia de carga secuencial causaba parpadeos y estados inconsistentes en la UI.

**Problema**: El evento `LoadProfileDetails` lanzaba dos llamadas a la API de forma secuencial. Si la primera respuesta tardaba más de lo esperado, el evento podía ser procesado un segunda vez antes de que la primera emisión de estado completara, produciendo estados entrelazados.

**Solución**: Se aplica el `concurrent` transformer de `flutter_bloc` al handler del evento `LoadProfileDetails` dentro de `ProfileBloc`. Este transformer permite que múltiples instancias del mismo evento se procesen concurrentemente en lugar de descartarse (droppable) o encolarse (sequential), garantizando que cada llamada a la API complete de forma independiente y que el estado final refleje la respuesta más reciente de cada fuente.

```dart
// ProfileBloc — registro del transformer
on<LoadProfileDetails>(
  _onLoadProfileDetails,
  transformer: concurrent(),
);

// Handler con carga paralela mediante Future.wait
Future<void> _onLoadProfileDetails(
  LoadProfileDetails event,
  Emitter<ProfileState> emit,
) async {
  emit(ProfileLoading());
  try {
    final results = await Future.wait([
      _profileRepository.getProfileDetails(event.profileId),
      _xpRepository.getXpData(event.profileId),
    ]);
    emit(ProfileDetailsLoaded(
      profile: results[0] as ProfileDetails,
      xpData: results[1] as XpData,
    ));
  } catch (e) {
    emit(ProfileError(message: e.toString()));
  }
}
```

`Future.wait` reduce la latencia total al ejecutar ambas peticiones HTTP en paralelo, en lugar de sumar sus tiempos de respuesta.

### 6. Adaptación del motor nutricional al lenguaje RPG

La pantalla `LogMealScreen` detecta el modo activo mediante `context.read<ThemeBloc>().state.isChildMode` y renderiza dos variantes del componente de resultado de bolus (`_BolusTrayResultScreen`):

- **Modo Adulto**: Tabla técnica con desglose por ingrediente, unidades de insulina en formato decimal, campo editable de dosis administrada.
- **Modo Niño**: Título "¡Tu poción está lista!", la dosis expresada como "X pociones de insulina mágica", indicador de color con texto contextual ("poción ligera" / "poción potente" / "poción épica"), animación de partículas al confirmar.

---

## Consecuencias

### Positivas

- **Mejora de adherencia documentable**: El sistema de XP crea un ciclo de refuerzo positivo medible. El porcentaje de días con al menos una comida registrada puede usarse como métrica de adherencia en estudios clínicos futuros.
- **Reducción de ansiedad clínica**: La recontextualización narrativa desvincula emocionalmente el acto de gestionar la diabetes del estrés asociado, especialmente en contextos sociales.
- **Arquitectura extensible**: El sistema de XP y medallas está desacoplado del resto del motor nutricional. Añadir nuevas medallas o acciones recompensadas no requiere cambios en la lógica de dominio, solo en `XPRepository` y en la capa de presentación.
- **Datos de adherencia para el guardián**: Los padres pueden ver el historial de XP de su hijo como indicador indirecto de la adherencia al registro.
- **Paridad funcional garantizada**: El modo niño utiliza exactamente los mismos endpoints de API y la misma lógica de dominio que el modo adulto. No existe riesgo de divergencia clínica entre modos.

### Negativas y trade-offs

- **Complejidad de mantenimiento de la capa de presentación**: Cada pantalla del flujo nutricional y de glucosa requiere una variante visual para modo niño. Esto duplica efectivamente el código de presentación en esas pantallas.
- **Riesgo de infantilización**: Si un adolescente de 12–14 años percibe el modo niño como demasiado infantil, puede generar rechazo. La solución parcial es que el guardián puede desactivar el modo niño desde la configuración del perfil, aunque esta funcionalidad no está implementada en la versión inicial.
- **Dependencia de XPRepository en el flujo de registro**: La integración del otorgamiento de XP en el endpoint `POST /meals` introduce una dependencia cruzada entre el módulo nutricional y el módulo de gamificación. Esta dependencia está mitigada mediante try/except con logging (ver ADR-015), garantizando que un fallo en el sistema de XP no bloquee el registro de la comida.

---

## Alternativas Consideradas

### Alternativa A: Aplicación separada para niños

Crear una aplicación Flutter independiente para el modo niño, compartiendo únicamente la API. Se descartó porque duplica el esfuerzo de mantenimiento, complica el sistema de autenticación y el guardián necesitaría gestionar dos aplicaciones distintas.

### Alternativa B: Puntos de recompensa sin nivel RPG

Implementar un sistema de puntos simple sin niveles ni temática narrativa. Se descartó porque la investigación en gamificación terapéutica indica que los sistemas de progresión con narrativa producen mayor engagement a largo plazo que los sistemas de puntos sin contexto.

### Alternativa C: Gamificación mediante tabla de clasificación familiar

Un sistema donde el niño compite con sus registros anteriores o con registros anónimos de otros pacientes. Se descartó por motivos de privacidad (datos de salud de menores) y por el riesgo de desmotivar a pacientes que tengan peor control glucémico de forma temporal (por ejemplo, durante una infección o un período de estrés).

### Alternativa D: Integración con plataformas de gaming existentes (Roblox, Minecraft)

Explorar APIs de gamificación de plataformas populares entre niños. Se descartó por dependencia de terceros, complejidad de integración y ausencia de control sobre cambios en las APIs externas.
