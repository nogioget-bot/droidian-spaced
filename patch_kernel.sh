#!/bin/bash
set -e # Останавливать скрипт при любой критической ошибке

echo "=== СТАРТ СКРИПТА АВТОПОЧИНКИ ИСХОДНИКОВ ==="

# 1. Отключаем жесткий режим Werror в главном Makefile и глушим варнинги
if [ -f Makefile ]; then
  echo "[+] Отключаем режим Werror и глушим warnings в главном Makefile..."
  sed -i 's/-Werror//g' Makefile
  sed -i 's/KBUILD_CFLAGS += -Werror//g' Makefile
  sed -i 's/KBUILD_CFLAGS   :=/KBUILD_CFLAGS   := -w /g' Makefile
fi

# 2. Фиксим пути трейсинга подсистемы uifirst (Oppo/Realme)
if [ -f kernel/uifirst/uifirst_sched_trace.h ]; then
  echo "[+] Исправляем пути трейсинга для uifirst..."
  mkdir -p include/trace/events
  cp kernel/uifirst/uifirst_sched_trace.h include/trace/events/uifirst_sched_trace.h
  cp kernel/uifirst/uifirst_sched_trace.h include/uifirst_sched_trace.h
  sed -i 's|#define TRACE_INCLUDE_PATH .|#define TRACE_INCLUDE_PATH ../../kernel/uifirst|g' kernel/uifirst/uifirst_sched_futex.c || true
fi

# 3. Фиксим ошибку инлайна (inlining failed) в oplus_wakelock_profiler_mtk.c
if [ -f drivers/base/power/owakelock/oplus_wakelock_profiler_mtk.c ]; then
  echo "[+] Убираем ломающий extern inline у функции ws_all_release..."
  sed -i 's/extern inline bool ws_all_release/bool ws_all_release/g' drivers/base/power/owakelock/oplus_wakelock_profiler_mtk.c
fi

# 4. Фиксим опечатку вендора с флагом -implicit-function-declaration
echo "[+] Исправляем опечатку в имени флага декларации функций..."
for file in Makefile arch/arm64/Makefile; do
  if [ -f "$file" ]; then
    sed -i 's/-implicit-function-declaration/-Wimplicit-function-declaration/g' "$file"
  fi
done

# 5. Ищем и линкуем аудио-заголовки MediaTek DSP
echo "[+] Поиск и линковка mtk-dsp-mem-control.h и его зависимостей..."
DSP_H_PATH=$(find . -name "mtk-dsp-mem-control.h" -print -quit)
if [ ! -z "$DSP_H_PATH" ]; then
  cp "$DSP_H_PATH" include/
fi

# НОВЫЙ ФИКС: Ищем сопутствующий mtk-base-dsp.h и кидаем туда же
DSP_BASE_H=$(find . -name "mtk-base-dsp.h" -print -quit)
if [ ! -z "$DSP_BASE_H" ]; then
  echo "[+] Найдена зависимость DSP: $DSP_BASE_H, копируем в include/"
  cp "$DSP_BASE_H" include/
fi

# 6. Фиксим dt_idle_states.h для cpuidle подсистемы управления питанием
echo "[+] Подсовываем dt_idle_states.h для cpuidle..."
IDLE_H_PATH=$(find . -name "dt_idle_states.h" -print -quit)
if [ ! -z "$IDLE_H_PATH" ]; then
  cp "$IDLE_H_PATH" include/
  cp "$IDLE_H_PATH" include/linux/
else
  echo '#include <linux/cpuidle.h>' > include/dt_idle_states.h
  echo '#include <linux/cpuidle.h>' > include/linux/dt_idle_states.h
fi

# 7. Фиксим ошибку инлайна (inlining failed) для ksm_flock в keyslot-manager.h
if [ -f include/linux/keyslot-manager.h ]; then
  echo "[+] Убираем inline у функции ksm_flock..."
  sed -i 's/inline void ksm_flock/void ksm_flock/g' include/linux/keyslot-manager.h
fi

# 8. НОВЫЙ ФИКС: Ищем helio-dvfsrc-qos.h и вытаскиваем в глобальные инклуды
echo "[+] Поиск и исправление путей для helio-dvfsrc-qos.h..."
DVFSRC_H=$(find . -name "helio-dvfsrc-qos.h" -print -quit)
if [ ! -z "$DVFSRC_H" ]; then
  cp "$DVFSRC_H" include/
  cp "$DVFSRC_H" include/linux/
fi

echo "=== АВТОПОЧИНКА УСПЕШНО ЗАВЕРШЕНА ==="
