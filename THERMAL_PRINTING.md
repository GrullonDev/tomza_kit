# Thermal Printing Optimization - TomzaKit

## 📋 Resumen

TomzaKit ahora incluye generación de PDFs optimizados para impresoras térmicas Bixolon, eliminando las líneas blancas horizontales que aparecían en el texto debido al anti-aliasing de fuentes.

## ✨ Características

### Optimizaciones Implementadas

1. **Fuentes Bold Monoespaciadas**
   - Roboto Mono Bold como fuente principal
   - Tamaños grandes (12-24pt) para máxima claridad
   - Sin anti-aliasing que cause líneas grises

2. **Sin Compresión PDF**
   - Deshabilitada la compresión para evitar artifacts
   - Fondos blancos puros (sin grises)
   - Texto negro puro (sin grises)

3. **Formato Optimizado para 3 Pulgadas**
   - 576 dots de ancho @ 203 DPI
   - Márgenes mínimos para aprovechar el papel
   - Layout específico para impresoras térmicas

## 🚀 Uso

### 1. Generar una Factura

```dart
import 'package:tomza_kit/tomza_kit.dart';

// Crear generador
final generator = ThermalPdfGenerator();
await generator.initialize();

// Generar PDF
final pdfBytes = await generator.generateInvoice(
  invoiceNumber: 'FAC-001-2024',
  date: '11/12/2024',
  customerName: 'Juan Pérez',
  customerInfo: 'NIT: 1234567-8',
  items: [
    InvoiceItem(
      description: 'Producto A',
      quantity: 2,
      unitPrice: 15.50,
      total: 31.00,
    ),
  ],
  subtotal: 31.00,
  tax: 3.72,
  total: 34.72,
  footer: 'Gracias por su compra',
);

// Guardar a archivo
final file = File('factura.pdf');
await file.writeAsBytes(pdfBytes);
```

### 2. Imprimir el PDF

```dart
import 'package:tomza_kit/tomza_kit.dart';

// Imprimir usando el método optimizado
await NativeBixolon.printPdfAsImageOverBt(
  file.path,
  printerAddress,
  options: {
    'threshold': 215,
    'printWidth': 576,
  },
);
```

### 3. Generar un Recibo

```dart
final pdfBytes = await generator.generateReceipt(
  receiptNumber: 'REC-001',
  date: '11/12/2024',
  description: 'Pago de factura FAC-001',
  amount: 100.00,
  paymentMethod: 'Efectivo',
  footer: 'Recibo válido como comprobante',
);
```

### 4. Documento Genérico

```dart
final pdfBytes = await generator.generateDocument(
  title: 'NOTA DE ENTREGA',
  sections: [
    DocumentSection(
      title: 'Cliente',
      content: 'Juan Pérez\nZona 10, Guatemala',
    ),
    DocumentSection(
      title: 'Productos',
      content: '- Producto A x2\n- Producto B x1',
    ),
  ],
  footer: 'Firma: ______________',
);
```

## 📦 Clases Principales

### `ThermalOptimizer`

Utilidades para optimización térmica:

- `loadThermalFont()` - Carga fuente Roboto Mono Bold
- `thermalTextStyle()` - Estilos de texto optimizados
- `thermal3InchFormat` - Formato de página de 3"
- `createThermalDocument()` - Crea documento sin compresión
- `thermalImage()` - Widget de imagen optimizado
- `thermalQrCode()` - Widget de QR code

### `ThermalPdfGenerator`

Generador de documentos:

- `generateInvoice()` - Genera factura completa
- `generateReceipt()` - Genera recibo simple
- `generateDocument()` - Genera documento personalizado

### Modelos

- `InvoiceItem` - Item de factura con descripción, cantidad, precio
- `DocumentSection` - Sección de documento con título y contenido

## 🎨 Personalización

### Estilos de Texto

```dart
// Encabezado grande
ThermalOptimizer.thermalHeaderStyle(
  font: font,
  fontSize: 24,
)

// Texto normal
ThermalOptimizer.thermalBodyStyle(
  font: font,
  fontSize: 12,
)

// Texto pequeño
ThermalOptimizer.thermalSmallStyle(
  font: font,
  fontSize: 10,
)
```

### Layout

```dart
// Espaciado vertical
ThermalOptimizer.verticalSpace(8)

// Línea divisoria
ThermalOptimizer.divider(thickness: 2)

// Caja con borde
ThermalOptimizer.borderedBox(
  child: Text('Contenido'),
  borderWidth: 1,
)
```

## 🔧 Configuración Técnica

### Especificaciones de Impresora

- **Ancho**: 3 pulgadas (576 dots @ 203 DPI)
- **Resolución**: 203 DPI
- **Color**: Monocromo (blanco y negro)
- **Formato**: Papel continuo

### Tamaños de Fuente Recomendados

- **Encabezados**: 20-24pt
- **Texto normal**: 12-14pt
- **Texto pequeño**: 9-11pt
- **Mínimo legible**: 9pt

### Parámetros de Impresión

```dart
options: {
  'threshold': 215,      // Umbral para conversión B/N
  'printWidth': 576,     // Ancho en dots
  'chunkSize': 256,      // Tamaño de chunk BT
  'interChunkDelayMs': 20, // Delay entre chunks
}
```

## ✅ Ventajas vs Método Anterior

| Aspecto | Antes | Ahora |
|---------|-------|-------|
| **Texto** | ❌ Líneas blancas | ✅ Texto nítido |
| **Fuente** | ❌ Variable con anti-aliasing | ✅ Roboto Mono Bold |
| **Compresión** | ❌ Activada (artifacts) | ✅ Desactivada |
| **Tamaño** | ❌ Pequeño (difícil de leer) | ✅ Grande y legible |
| **QR/Logos** | ✅ Funcionaban bien | ✅ Siguen funcionando |

## 📝 Ejemplo Completo

Ver `example/thermal_pdf_example.dart` para un ejemplo completo de generación de factura.

## 🐛 Troubleshooting

### El texto sigue teniendo líneas blancas

1. Verificar que la fuente Roboto Mono Bold esté en `assets/fonts/`
2. Confirmar que `compress: false` en el documento
3. Ajustar `threshold` en opciones de impresión (probar 200-220)

### El PDF es muy grande

Esto es normal - sin compresión los PDFs son más grandes pero imprimen mejor. El tamaño no afecta la velocidad de impresión.

### La fuente no se carga

Si Roboto Mono Bold no está disponible, el sistema usa Courier como fallback. Para mejor calidad, asegurar que el archivo TTF esté presente.

## 🔄 Integración con Flujo Existente

```dart
// 1. Generar PDF optimizado
final pdfBytes = await ThermalPdfGenerator().generateInvoice(...);

// 2. Guardar a archivo
final file = await savePdfToFile(pdfBytes);

// 3. Imprimir usando método existente
await NativeBixolon.printPdfAsImageOverBt(
  file.path,
  printerAddress,
  options: {'threshold': 215, 'printWidth': 576},
);
```

El flujo de impresión no cambia - solo mejora la calidad del PDF generado.
