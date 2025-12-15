#!/bin/bash

# archivo de salida
OUTPUT="task_presentation.txt"

# limpiar salida anterior
> "$OUTPUT"

# -------------------------------------------------------------------------- \\
# ESTRUCTURA DE CARPETAS
# -------------------------------------------------------------------------- \\
echo "//--------------------------------------------------------------------------\\\\" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "// estructura:" >> "$OUTPUT"

# mostrar estructura de ./lib
tree ./lib/features/tasks/presentation >> "$OUTPUT"

# también incluir pubspec.yaml en estructura
echo "" >> "$OUTPUT"
echo "./pubspec.yaml" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "//--------------------------------------------------------------------------\\\\" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# -------------------------------------------------------------------------- \\
# CONTENIDO DE ARCHIVOS
# -------------------------------------------------------------------------- \\
# listar archivos de ./lib y pubspec.yaml
FILES=$(find ./lib/features/tasks/presentation -type f) 
FILES="$FILES ./pubspec.yaml"

for f in $FILES; do
    echo "// ================ $f ============== \\\\" >> "$OUTPUT"
    cat "$f" >> "$OUTPUT"
    echo -e "\n" >> "$OUTPUT"
done
