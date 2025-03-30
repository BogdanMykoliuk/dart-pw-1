import 'dart:io';

void main() {
  performTask1();
  performTask2();
}

/// Reads a double value from the console or returns the default value if input is empty or invalid.
double inputDoubleOr(String prompt, {double defaultValue = 0.0}) {
  stdout.write('$prompt (default: $defaultValue): ');
  final input = stdin.readLineSync()?.trim();
  if (input == null || input.isEmpty) {
    print('Empty input, using default value: $defaultValue');
    return defaultValue;
  }
  final value = double.tryParse(input);
  if (value == null) {
    print('Invalid input, using default value: $defaultValue');
    return defaultValue;
  }
  return value;
}

/// Performs the first task: calculates fuel compositions and heating values.
void performTask1() {
  print('Завдання 1 (Варіант 12 => брати рядок 2 з таблиці 1.3)\n');

  // ***** ЗМІНИТЬ ТУТ: нові defaultValue для варіанта 2 *****
  final hydrogenPercent = inputDoubleOr("Вміст водню, %",  defaultValue: 4.2);
  final carbonPercent   = inputDoubleOr("Вміст вуглецю, %", defaultValue: 62.1);
  final sulfurPercent   = inputDoubleOr("Вміст сірки, %",   defaultValue: 3.3);
  final nitrogenPercent = inputDoubleOr("Вміст азоту, %",  defaultValue: 1.2);
  final oxygenPercent   = inputDoubleOr("Вміст кисню, %",  defaultValue: 6.4);
  final waterPercent    = inputDoubleOr("Вміст вологи, %", defaultValue: 7.0);
  final ashPercent      = inputDoubleOr("Вміст попелу, %", defaultValue: 15.8);

  // Conversion coefficients (from working mass to dry/combustible)
  final kRs = 100 / (100 - waterPercent);
  final kRg = 100 / (100 - waterPercent - ashPercent);

  // Calculate dry mass composition
  final dryHydrogen = hydrogenPercent * kRs;
  final dryCarbon   = carbonPercent   * kRs;
  final drySulfur   = sulfurPercent   * kRs;
  final dryNitrogen = nitrogenPercent * kRs;
  final dryOxygen   = oxygenPercent   * kRs;
  final dryAsh      = ashPercent      * kRs;

  // Calculate combustible mass composition
  final combHydrogen = hydrogenPercent * kRg;
  final combCarbon   = carbonPercent   * kRg;
  final combSulfur   = sulfurPercent   * kRg;
  final combNitrogen = nitrogenPercent * kRg;
  final combOxygen   = oxygenPercent   * kRg;

  // Calculate lower heating values (in МДж/кг) using formula Mendeléev
  final qrN = (339 * carbonPercent
             + 1030 * hydrogenPercent
             - 108.8 * (oxygenPercent - sulfurPercent)
             - 25 * waterPercent) / 1000;

  // Перерахунок QrN у суху (QsN) і горючу (QhN) маси, за методикою з таблиці 1.2:
  final qsN = (qrN + 0.025 * waterPercent) * 100 / (100 - waterPercent);
  final qhN = (qrN + 0.025 * waterPercent) * 100
              / (100 - waterPercent - ashPercent);

  // Підсумковий вивід
  print('''
Завдання 1 результати (Варіант 12 => рядок 2 таблиці 1.3):
Компонентний склад (робоча маса):
  H^P: ${hydrogenPercent.toStringAsFixed(2)}%, 
  C^P: ${carbonPercent.toStringAsFixed(2)}%, 
  S^P: ${sulfurPercent.toStringAsFixed(2)}%, 
  N^P: ${nitrogenPercent.toStringAsFixed(2)}%, 
  O^P: ${oxygenPercent.toStringAsFixed(2)}%, 
  W^P: ${waterPercent.toStringAsFixed(2)}%, 
  A^P: ${ashPercent.toStringAsFixed(2)}%

Коефіцієнти:
  Переходу до сухої маси (Krs): ${kRs.toStringAsFixed(3)}
  Переходу до горючої маси (Krg): ${kRg.toStringAsFixed(3)}

Склад сухої маси:
  H^C: ${dryHydrogen.toStringAsFixed(2)}%, 
  C^C: ${dryCarbon.toStringAsFixed(2)}%, 
  S^C: ${drySulfur.toStringAsFixed(2)}%, 
  N^C: ${dryNitrogen.toStringAsFixed(2)}%, 
  O^C: ${dryOxygen.toStringAsFixed(2)}%, 
  A^C: ${dryAsh.toStringAsFixed(2)}%

Склад горючої маси:
  H^G: ${combHydrogen.toStringAsFixed(2)}%, 
  C^G: ${combCarbon.toStringAsFixed(2)}%, 
  S^G: ${combSulfur.toStringAsFixed(2)}%, 
  N^G: ${combNitrogen.toStringAsFixed(2)}%, 
  O^G: ${combOxygen.toStringAsFixed(2)}%

Нижча теплота згоряння:
  Робоча маса (QrN): ${qrN.toStringAsFixed(3)} МДж/кг
  Суха маса  (QsN): ${qsN.toStringAsFixed(3)} МДж/кг
  Горюча маса(QhN): ${qhN.toStringAsFixed(3)} МДж/кг
''');
}

/// Performs the second task: calculates the working mass composition and adjusted heating value for mazut.
void performTask2() {
  print('Завдання 2:\n');

  // Ці значення беремо з прикладу по мазуту (можна змінити, якщо у вас інші вимоги)
  final hg   = inputDoubleOr("Вміст водню, %", defaultValue: 11.2);
  final cg   = inputDoubleOr("Вміст вуглецю, %", defaultValue: 85.5);
  final og   = inputDoubleOr("Вміст кисню, %",  defaultValue: 0.8);
  final sg   = inputDoubleOr("Вміст сірки, %",  defaultValue: 2.5);
  final qdaf = inputDoubleOr("Нижча теплота згоряння горючої маси мазуту, МДж/кг", defaultValue: 40.40);
  final wg   = inputDoubleOr("Вологість робочої маси палива, %", defaultValue: 2.00);
  final ag   = inputDoubleOr("Зольність сухої маси, %",          defaultValue: 0.15);
  final vg   = inputDoubleOr("Вміст ванадію, мг/кг",             defaultValue: 333.3);

  // Calculate the working mass composition of mazut
  final cp = cg * (100 - wg - ag) / 100;
  final hp = hg * (100 - wg - ag) / 100;
  final op = og * (100 - wg - ag) / 100;

  // У початковому коді є приклад перерахунку сірки (sp) і попелу (ap).
  // Зверніть увагу, що там був неточний вираз: sg * (100 - wg*0.1 - ag*0.1)/100,
  // найпевніше мався на увазі просто (100 - wg - ag).
  // Якщо ви хочете залишити оригінал – можна залишити.
  final sp = sg * (100 - wg - ag) / 100;

  final ap = ag * (100 - wg) / 100;
  final vp = vg * (100 - wg) / 100;

  // Adjusted lower heating value for the working mass
  final qp = qdaf * ((100 - wg - ag) / 100) - 0.025 * wg;

  // Output results
  print('''
Завдання 2 результати (Приклад для мазуту):
Склад горючої маси мазуту:
  H^Г: ${hg.toStringAsFixed(2)}%, 
  C^Г: ${cg.toStringAsFixed(2)}%, 
  S^Г: ${sg.toStringAsFixed(2)}%, 
  O^Г: ${og.toStringAsFixed(2)}%, 
  V^Г: ${vg.toStringAsFixed(2)} мг/кг, 
  W^Г: ${wg.toStringAsFixed(2)}%, 
  A^Г: ${ag.toStringAsFixed(2)}%

Склад робочої маси мазуту:
  H^Р: ${hp.toStringAsFixed(2)}%, 
  C^Р: ${cp.toStringAsFixed(2)}%, 
  S^Р: ${sp.toStringAsFixed(2)}%, 
  O^Р: ${op.toStringAsFixed(2)}%, 
  V^Р: ${vp.toStringAsFixed(2)} мг/кг, 
  A^Р: ${ap.toStringAsFixed(2)}%

Нижча теплота згоряння (робоча маса): ${qp.toStringAsFixed(3)} МДж/кг
''');
}
