// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CurrenciesTable extends Currencies
    with TableInfo<$CurrenciesTable, Currency> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CurrenciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 8,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _decimalDigitsMeta = const VerificationMeta(
    'decimalDigits',
  );
  @override
  late final GeneratedColumn<int> decimalDigits = GeneratedColumn<int>(
    'decimal_digits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isBaseMeta = const VerificationMeta('isBase');
  @override
  late final GeneratedColumn<bool> isBase = GeneratedColumn<bool>(
    'is_base',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_base" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    name,
    symbol,
    decimalDigits,
    isActive,
    isBase,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'currencies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Currency> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('decimal_digits')) {
      context.handle(
        _decimalDigitsMeta,
        decimalDigits.isAcceptableOrUnknown(
          data['decimal_digits']!,
          _decimalDigitsMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('is_base')) {
      context.handle(
        _isBaseMeta,
        isBase.isAcceptableOrUnknown(data['is_base']!, _isBaseMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  Currency map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Currency(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      decimalDigits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}decimal_digits'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      isBase: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_base'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CurrenciesTable createAlias(String alias) {
    return $CurrenciesTable(attachedDatabase, alias);
  }
}

class Currency extends DataClass implements Insertable<Currency> {
  final String code;
  final String name;
  final String symbol;
  final int decimalDigits;
  final bool isActive;
  final bool isBase;
  final DateTime createdAt;
  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.decimalDigits,
    required this.isActive,
    required this.isBase,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['symbol'] = Variable<String>(symbol);
    map['decimal_digits'] = Variable<int>(decimalDigits);
    map['is_active'] = Variable<bool>(isActive);
    map['is_base'] = Variable<bool>(isBase);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CurrenciesCompanion toCompanion(bool nullToAbsent) {
    return CurrenciesCompanion(
      code: Value(code),
      name: Value(name),
      symbol: Value(symbol),
      decimalDigits: Value(decimalDigits),
      isActive: Value(isActive),
      isBase: Value(isBase),
      createdAt: Value(createdAt),
    );
  }

  factory Currency.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Currency(
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      symbol: serializer.fromJson<String>(json['symbol']),
      decimalDigits: serializer.fromJson<int>(json['decimalDigits']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isBase: serializer.fromJson<bool>(json['isBase']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'symbol': serializer.toJson<String>(symbol),
      'decimalDigits': serializer.toJson<int>(decimalDigits),
      'isActive': serializer.toJson<bool>(isActive),
      'isBase': serializer.toJson<bool>(isBase),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Currency copyWith({
    String? code,
    String? name,
    String? symbol,
    int? decimalDigits,
    bool? isActive,
    bool? isBase,
    DateTime? createdAt,
  }) => Currency(
    code: code ?? this.code,
    name: name ?? this.name,
    symbol: symbol ?? this.symbol,
    decimalDigits: decimalDigits ?? this.decimalDigits,
    isActive: isActive ?? this.isActive,
    isBase: isBase ?? this.isBase,
    createdAt: createdAt ?? this.createdAt,
  );
  Currency copyWithCompanion(CurrenciesCompanion data) {
    return Currency(
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      decimalDigits: data.decimalDigits.present
          ? data.decimalDigits.value
          : this.decimalDigits,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isBase: data.isBase.present ? data.isBase.value : this.isBase,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Currency(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('symbol: $symbol, ')
          ..write('decimalDigits: $decimalDigits, ')
          ..write('isActive: $isActive, ')
          ..write('isBase: $isBase, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    code,
    name,
    symbol,
    decimalDigits,
    isActive,
    isBase,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Currency &&
          other.code == this.code &&
          other.name == this.name &&
          other.symbol == this.symbol &&
          other.decimalDigits == this.decimalDigits &&
          other.isActive == this.isActive &&
          other.isBase == this.isBase &&
          other.createdAt == this.createdAt);
}

class CurrenciesCompanion extends UpdateCompanion<Currency> {
  final Value<String> code;
  final Value<String> name;
  final Value<String> symbol;
  final Value<int> decimalDigits;
  final Value<bool> isActive;
  final Value<bool> isBase;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CurrenciesCompanion({
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.symbol = const Value.absent(),
    this.decimalDigits = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isBase = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CurrenciesCompanion.insert({
    required String code,
    required String name,
    required String symbol,
    this.decimalDigits = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isBase = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       name = Value(name),
       symbol = Value(symbol);
  static Insertable<Currency> custom({
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? symbol,
    Expression<int>? decimalDigits,
    Expression<bool>? isActive,
    Expression<bool>? isBase,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (symbol != null) 'symbol': symbol,
      if (decimalDigits != null) 'decimal_digits': decimalDigits,
      if (isActive != null) 'is_active': isActive,
      if (isBase != null) 'is_base': isBase,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CurrenciesCompanion copyWith({
    Value<String>? code,
    Value<String>? name,
    Value<String>? symbol,
    Value<int>? decimalDigits,
    Value<bool>? isActive,
    Value<bool>? isBase,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CurrenciesCompanion(
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      decimalDigits: decimalDigits ?? this.decimalDigits,
      isActive: isActive ?? this.isActive,
      isBase: isBase ?? this.isBase,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (decimalDigits.present) {
      map['decimal_digits'] = Variable<int>(decimalDigits.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isBase.present) {
      map['is_base'] = Variable<bool>(isBase.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CurrenciesCompanion(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('symbol: $symbol, ')
          ..write('decimalDigits: $decimalDigits, ')
          ..write('isActive: $isActive, ')
          ..write('isBase: $isBase, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unidad'),
  );
  static const VerificationMeta _trackInventoryMeta = const VerificationMeta(
    'trackInventory',
  );
  @override
  late final GeneratedColumn<bool> trackInventory = GeneratedColumn<bool>(
    'track_inventory',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("track_inventory" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sku,
    name,
    description,
    category,
    unit,
    trackInventory,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<Product> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('track_inventory')) {
      context.handle(
        _trackInventoryMeta,
        trackInventory.isAcceptableOrUnknown(
          data['track_inventory']!,
          _trackInventoryMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      trackInventory: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}track_inventory'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final String id;
  final String sku;
  final String name;
  final String? description;
  final String? category;
  final String unit;
  final bool trackInventory;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Product({
    required this.id,
    required this.sku,
    required this.name,
    this.description,
    this.category,
    required this.unit,
    required this.trackInventory,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sku'] = Variable<String>(sku);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['unit'] = Variable<String>(unit);
    map['track_inventory'] = Variable<bool>(trackInventory);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      sku: Value(sku),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      unit: Value(unit),
      trackInventory: Value(trackInventory),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Product.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<String>(json['id']),
      sku: serializer.fromJson<String>(json['sku']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      category: serializer.fromJson<String?>(json['category']),
      unit: serializer.fromJson<String>(json['unit']),
      trackInventory: serializer.fromJson<bool>(json['trackInventory']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sku': serializer.toJson<String>(sku),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'category': serializer.toJson<String?>(category),
      'unit': serializer.toJson<String>(unit),
      'trackInventory': serializer.toJson<bool>(trackInventory),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Product copyWith({
    String? id,
    String? sku,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> category = const Value.absent(),
    String? unit,
    bool? trackInventory,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Product(
    id: id ?? this.id,
    sku: sku ?? this.sku,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    category: category.present ? category.value : this.category,
    unit: unit ?? this.unit,
    trackInventory: trackInventory ?? this.trackInventory,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      sku: data.sku.present ? data.sku.value : this.sku,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      category: data.category.present ? data.category.value : this.category,
      unit: data.unit.present ? data.unit.value : this.unit,
      trackInventory: data.trackInventory.present
          ? data.trackInventory.value
          : this.trackInventory,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('sku: $sku, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('unit: $unit, ')
          ..write('trackInventory: $trackInventory, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sku,
    name,
    description,
    category,
    unit,
    trackInventory,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.sku == this.sku &&
          other.name == this.name &&
          other.description == this.description &&
          other.category == this.category &&
          other.unit == this.unit &&
          other.trackInventory == this.trackInventory &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<String> id;
  final Value<String> sku;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> category;
  final Value<String> unit;
  final Value<bool> trackInventory;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.sku = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.unit = const Value.absent(),
    this.trackInventory = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String sku,
    required String name,
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.unit = const Value.absent(),
    this.trackInventory = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sku = Value(sku),
       name = Value(name);
  static Insertable<Product> custom({
    Expression<String>? id,
    Expression<String>? sku,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? category,
    Expression<String>? unit,
    Expression<bool>? trackInventory,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sku != null) 'sku': sku,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (unit != null) 'unit': unit,
      if (trackInventory != null) 'track_inventory': trackInventory,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? sku,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? category,
    Value<String>? unit,
    Value<bool>? trackInventory,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      trackInventory: trackInventory ?? this.trackInventory,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (trackInventory.present) {
      map['track_inventory'] = Variable<bool>(trackInventory.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('sku: $sku, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('unit: $unit, ')
          ..write('trackInventory: $trackInventory, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductPricesTable extends ProductPrices
    with TableInfo<$ProductPricesTable, ProductPrice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductPricesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES currencies (code)',
    ),
  );
  static const VerificationMeta _amountMinorUnitsMeta = const VerificationMeta(
    'amountMinorUnits',
  );
  @override
  late final GeneratedColumn<int> amountMinorUnits = GeneratedColumn<int>(
    'amount_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    productId,
    currencyCode,
    amountMinorUnits,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_prices';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductPrice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('amount_minor_units')) {
      context.handle(
        _amountMinorUnitsMeta,
        amountMinorUnits.isAcceptableOrUnknown(
          data['amount_minor_units']!,
          _amountMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorUnitsMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {productId, currencyCode};
  @override
  ProductPrice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductPrice(
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      amountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor_units'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProductPricesTable createAlias(String alias) {
    return $ProductPricesTable(attachedDatabase, alias);
  }
}

class ProductPrice extends DataClass implements Insertable<ProductPrice> {
  final String productId;
  final String currencyCode;
  final int amountMinorUnits;
  final DateTime updatedAt;
  const ProductPrice({
    required this.productId,
    required this.currencyCode,
    required this.amountMinorUnits,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['product_id'] = Variable<String>(productId);
    map['currency_code'] = Variable<String>(currencyCode);
    map['amount_minor_units'] = Variable<int>(amountMinorUnits);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProductPricesCompanion toCompanion(bool nullToAbsent) {
    return ProductPricesCompanion(
      productId: Value(productId),
      currencyCode: Value(currencyCode),
      amountMinorUnits: Value(amountMinorUnits),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProductPrice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductPrice(
      productId: serializer.fromJson<String>(json['productId']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      amountMinorUnits: serializer.fromJson<int>(json['amountMinorUnits']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'productId': serializer.toJson<String>(productId),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'amountMinorUnits': serializer.toJson<int>(amountMinorUnits),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProductPrice copyWith({
    String? productId,
    String? currencyCode,
    int? amountMinorUnits,
    DateTime? updatedAt,
  }) => ProductPrice(
    productId: productId ?? this.productId,
    currencyCode: currencyCode ?? this.currencyCode,
    amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProductPrice copyWithCompanion(ProductPricesCompanion data) {
    return ProductPrice(
      productId: data.productId.present ? data.productId.value : this.productId,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      amountMinorUnits: data.amountMinorUnits.present
          ? data.amountMinorUnits.value
          : this.amountMinorUnits,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductPrice(')
          ..write('productId: $productId, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(productId, currencyCode, amountMinorUnits, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductPrice &&
          other.productId == this.productId &&
          other.currencyCode == this.currencyCode &&
          other.amountMinorUnits == this.amountMinorUnits &&
          other.updatedAt == this.updatedAt);
}

class ProductPricesCompanion extends UpdateCompanion<ProductPrice> {
  final Value<String> productId;
  final Value<String> currencyCode;
  final Value<int> amountMinorUnits;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProductPricesCompanion({
    this.productId = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.amountMinorUnits = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductPricesCompanion.insert({
    required String productId,
    required String currencyCode,
    required int amountMinorUnits,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : productId = Value(productId),
       currencyCode = Value(currencyCode),
       amountMinorUnits = Value(amountMinorUnits);
  static Insertable<ProductPrice> custom({
    Expression<String>? productId,
    Expression<String>? currencyCode,
    Expression<int>? amountMinorUnits,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (productId != null) 'product_id': productId,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (amountMinorUnits != null) 'amount_minor_units': amountMinorUnits,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductPricesCompanion copyWith({
    Value<String>? productId,
    Value<String>? currencyCode,
    Value<int>? amountMinorUnits,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProductPricesCompanion(
      productId: productId ?? this.productId,
      currencyCode: currencyCode ?? this.currencyCode,
      amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (amountMinorUnits.present) {
      map['amount_minor_units'] = Variable<int>(amountMinorUnits.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductPricesCompanion(')
          ..write('productId: $productId, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryMovementsTable extends InventoryMovements
    with TableInfo<$InventoryMovementsTable, InventoryMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _movementTypeMeta = const VerificationMeta(
    'movementType',
  );
  @override
  late final GeneratedColumn<String> movementType = GeneratedColumn<String>(
    'movement_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMilliUnitsMeta =
      const VerificationMeta('quantityMilliUnits');
  @override
  late final GeneratedColumn<int> quantityMilliUnits = GeneratedColumn<int>(
    'quantity_milli_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 250,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correctionOfIdMeta = const VerificationMeta(
    'correctionOfId',
  );
  @override
  late final GeneratedColumn<String> correctionOfId = GeneratedColumn<String>(
    'correction_of_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES inventory_movements (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    movementType,
    quantityMilliUnits,
    reason,
    reference,
    correctionOfId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryMovement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('movement_type')) {
      context.handle(
        _movementTypeMeta,
        movementType.isAcceptableOrUnknown(
          data['movement_type']!,
          _movementTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_movementTypeMeta);
    }
    if (data.containsKey('quantity_milli_units')) {
      context.handle(
        _quantityMilliUnitsMeta,
        quantityMilliUnits.isAcceptableOrUnknown(
          data['quantity_milli_units']!,
          _quantityMilliUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityMilliUnitsMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('correction_of_id')) {
      context.handle(
        _correctionOfIdMeta,
        correctionOfId.isAcceptableOrUnknown(
          data['correction_of_id']!,
          _correctionOfIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryMovement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      movementType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movement_type'],
      )!,
      quantityMilliUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_milli_units'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      correctionOfId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}correction_of_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $InventoryMovementsTable createAlias(String alias) {
    return $InventoryMovementsTable(attachedDatabase, alias);
  }
}

class InventoryMovement extends DataClass
    implements Insertable<InventoryMovement> {
  final String id;
  final String productId;
  final String movementType;
  final int quantityMilliUnits;
  final String reason;
  final String? reference;
  final String? correctionOfId;
  final DateTime createdAt;
  const InventoryMovement({
    required this.id,
    required this.productId,
    required this.movementType,
    required this.quantityMilliUnits,
    required this.reason,
    this.reference,
    this.correctionOfId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['movement_type'] = Variable<String>(movementType);
    map['quantity_milli_units'] = Variable<int>(quantityMilliUnits);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    if (!nullToAbsent || correctionOfId != null) {
      map['correction_of_id'] = Variable<String>(correctionOfId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InventoryMovementsCompanion toCompanion(bool nullToAbsent) {
    return InventoryMovementsCompanion(
      id: Value(id),
      productId: Value(productId),
      movementType: Value(movementType),
      quantityMilliUnits: Value(quantityMilliUnits),
      reason: Value(reason),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      correctionOfId: correctionOfId == null && nullToAbsent
          ? const Value.absent()
          : Value(correctionOfId),
      createdAt: Value(createdAt),
    );
  }

  factory InventoryMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryMovement(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      movementType: serializer.fromJson<String>(json['movementType']),
      quantityMilliUnits: serializer.fromJson<int>(json['quantityMilliUnits']),
      reason: serializer.fromJson<String>(json['reason']),
      reference: serializer.fromJson<String?>(json['reference']),
      correctionOfId: serializer.fromJson<String?>(json['correctionOfId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'movementType': serializer.toJson<String>(movementType),
      'quantityMilliUnits': serializer.toJson<int>(quantityMilliUnits),
      'reason': serializer.toJson<String>(reason),
      'reference': serializer.toJson<String?>(reference),
      'correctionOfId': serializer.toJson<String?>(correctionOfId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InventoryMovement copyWith({
    String? id,
    String? productId,
    String? movementType,
    int? quantityMilliUnits,
    String? reason,
    Value<String?> reference = const Value.absent(),
    Value<String?> correctionOfId = const Value.absent(),
    DateTime? createdAt,
  }) => InventoryMovement(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    movementType: movementType ?? this.movementType,
    quantityMilliUnits: quantityMilliUnits ?? this.quantityMilliUnits,
    reason: reason ?? this.reason,
    reference: reference.present ? reference.value : this.reference,
    correctionOfId: correctionOfId.present
        ? correctionOfId.value
        : this.correctionOfId,
    createdAt: createdAt ?? this.createdAt,
  );
  InventoryMovement copyWithCompanion(InventoryMovementsCompanion data) {
    return InventoryMovement(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      movementType: data.movementType.present
          ? data.movementType.value
          : this.movementType,
      quantityMilliUnits: data.quantityMilliUnits.present
          ? data.quantityMilliUnits.value
          : this.quantityMilliUnits,
      reason: data.reason.present ? data.reason.value : this.reason,
      reference: data.reference.present ? data.reference.value : this.reference,
      correctionOfId: data.correctionOfId.present
          ? data.correctionOfId.value
          : this.correctionOfId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryMovement(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('movementType: $movementType, ')
          ..write('quantityMilliUnits: $quantityMilliUnits, ')
          ..write('reason: $reason, ')
          ..write('reference: $reference, ')
          ..write('correctionOfId: $correctionOfId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    movementType,
    quantityMilliUnits,
    reason,
    reference,
    correctionOfId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryMovement &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.movementType == this.movementType &&
          other.quantityMilliUnits == this.quantityMilliUnits &&
          other.reason == this.reason &&
          other.reference == this.reference &&
          other.correctionOfId == this.correctionOfId &&
          other.createdAt == this.createdAt);
}

class InventoryMovementsCompanion extends UpdateCompanion<InventoryMovement> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> movementType;
  final Value<int> quantityMilliUnits;
  final Value<String> reason;
  final Value<String?> reference;
  final Value<String?> correctionOfId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InventoryMovementsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.movementType = const Value.absent(),
    this.quantityMilliUnits = const Value.absent(),
    this.reason = const Value.absent(),
    this.reference = const Value.absent(),
    this.correctionOfId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryMovementsCompanion.insert({
    required String id,
    required String productId,
    required String movementType,
    required int quantityMilliUnits,
    required String reason,
    this.reference = const Value.absent(),
    this.correctionOfId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       movementType = Value(movementType),
       quantityMilliUnits = Value(quantityMilliUnits),
       reason = Value(reason);
  static Insertable<InventoryMovement> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? movementType,
    Expression<int>? quantityMilliUnits,
    Expression<String>? reason,
    Expression<String>? reference,
    Expression<String>? correctionOfId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (movementType != null) 'movement_type': movementType,
      if (quantityMilliUnits != null)
        'quantity_milli_units': quantityMilliUnits,
      if (reason != null) 'reason': reason,
      if (reference != null) 'reference': reference,
      if (correctionOfId != null) 'correction_of_id': correctionOfId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryMovementsCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? movementType,
    Value<int>? quantityMilliUnits,
    Value<String>? reason,
    Value<String?>? reference,
    Value<String?>? correctionOfId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return InventoryMovementsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      movementType: movementType ?? this.movementType,
      quantityMilliUnits: quantityMilliUnits ?? this.quantityMilliUnits,
      reason: reason ?? this.reason,
      reference: reference ?? this.reference,
      correctionOfId: correctionOfId ?? this.correctionOfId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (movementType.present) {
      map['movement_type'] = Variable<String>(movementType.value);
    }
    if (quantityMilliUnits.present) {
      map['quantity_milli_units'] = Variable<int>(quantityMilliUnits.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (correctionOfId.present) {
      map['correction_of_id'] = Variable<String>(correctionOfId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryMovementsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('movementType: $movementType, ')
          ..write('quantityMilliUnits: $quantityMilliUnits, ')
          ..write('reason: $reason, ')
          ..write('reference: $reference, ')
          ..write('correctionOfId: $correctionOfId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryBalancesTable extends InventoryBalances
    with TableInfo<$InventoryBalancesTable, InventoryBalance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryBalancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _quantityMilliUnitsMeta =
      const VerificationMeta('quantityMilliUnits');
  @override
  late final GeneratedColumn<int> quantityMilliUnits = GeneratedColumn<int>(
    'quantity_milli_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    productId,
    quantityMilliUnits,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_balances';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryBalance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity_milli_units')) {
      context.handle(
        _quantityMilliUnitsMeta,
        quantityMilliUnits.isAcceptableOrUnknown(
          data['quantity_milli_units']!,
          _quantityMilliUnitsMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {productId};
  @override
  InventoryBalance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryBalance(
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      quantityMilliUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_milli_units'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $InventoryBalancesTable createAlias(String alias) {
    return $InventoryBalancesTable(attachedDatabase, alias);
  }
}

class InventoryBalance extends DataClass
    implements Insertable<InventoryBalance> {
  final String productId;
  final int quantityMilliUnits;
  final DateTime updatedAt;
  const InventoryBalance({
    required this.productId,
    required this.quantityMilliUnits,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['product_id'] = Variable<String>(productId);
    map['quantity_milli_units'] = Variable<int>(quantityMilliUnits);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  InventoryBalancesCompanion toCompanion(bool nullToAbsent) {
    return InventoryBalancesCompanion(
      productId: Value(productId),
      quantityMilliUnits: Value(quantityMilliUnits),
      updatedAt: Value(updatedAt),
    );
  }

  factory InventoryBalance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryBalance(
      productId: serializer.fromJson<String>(json['productId']),
      quantityMilliUnits: serializer.fromJson<int>(json['quantityMilliUnits']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'productId': serializer.toJson<String>(productId),
      'quantityMilliUnits': serializer.toJson<int>(quantityMilliUnits),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  InventoryBalance copyWith({
    String? productId,
    int? quantityMilliUnits,
    DateTime? updatedAt,
  }) => InventoryBalance(
    productId: productId ?? this.productId,
    quantityMilliUnits: quantityMilliUnits ?? this.quantityMilliUnits,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  InventoryBalance copyWithCompanion(InventoryBalancesCompanion data) {
    return InventoryBalance(
      productId: data.productId.present ? data.productId.value : this.productId,
      quantityMilliUnits: data.quantityMilliUnits.present
          ? data.quantityMilliUnits.value
          : this.quantityMilliUnits,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryBalance(')
          ..write('productId: $productId, ')
          ..write('quantityMilliUnits: $quantityMilliUnits, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(productId, quantityMilliUnits, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryBalance &&
          other.productId == this.productId &&
          other.quantityMilliUnits == this.quantityMilliUnits &&
          other.updatedAt == this.updatedAt);
}

class InventoryBalancesCompanion extends UpdateCompanion<InventoryBalance> {
  final Value<String> productId;
  final Value<int> quantityMilliUnits;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const InventoryBalancesCompanion({
    this.productId = const Value.absent(),
    this.quantityMilliUnits = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryBalancesCompanion.insert({
    required String productId,
    this.quantityMilliUnits = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : productId = Value(productId);
  static Insertable<InventoryBalance> custom({
    Expression<String>? productId,
    Expression<int>? quantityMilliUnits,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (productId != null) 'product_id': productId,
      if (quantityMilliUnits != null)
        'quantity_milli_units': quantityMilliUnits,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryBalancesCompanion copyWith({
    Value<String>? productId,
    Value<int>? quantityMilliUnits,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return InventoryBalancesCompanion(
      productId: productId ?? this.productId,
      quantityMilliUnits: quantityMilliUnits ?? this.quantityMilliUnits,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (quantityMilliUnits.present) {
      map['quantity_milli_units'] = Variable<int>(quantityMilliUnits.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryBalancesCompanion(')
          ..write('productId: $productId, ')
          ..write('quantityMilliUnits: $quantityMilliUnits, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SuppliersTable extends Suppliers
    with TableInfo<$SuppliersTable, Supplier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 150,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxIdMeta = const VerificationMeta('taxId');
  @override
  late final GeneratedColumn<String> taxId = GeneratedColumn<String>(
    'tax_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    taxId,
    phone,
    email,
    address,
    notes,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suppliers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Supplier> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('tax_id')) {
      context.handle(
        _taxIdMeta,
        taxId.isAcceptableOrUnknown(data['tax_id']!, _taxIdMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Supplier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Supplier(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      taxId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tax_id'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SuppliersTable createAlias(String alias) {
    return $SuppliersTable(attachedDatabase, alias);
  }
}

class Supplier extends DataClass implements Insertable<Supplier> {
  final String id;
  final String name;
  final String? taxId;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Supplier({
    required this.id,
    required this.name,
    this.taxId,
    this.phone,
    this.email,
    this.address,
    this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || taxId != null) {
      map['tax_id'] = Variable<String>(taxId);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SuppliersCompanion toCompanion(bool nullToAbsent) {
    return SuppliersCompanion(
      id: Value(id),
      name: Value(name),
      taxId: taxId == null && nullToAbsent
          ? const Value.absent()
          : Value(taxId),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Supplier.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Supplier(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      taxId: serializer.fromJson<String?>(json['taxId']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'taxId': serializer.toJson<String?>(taxId),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Supplier copyWith({
    String? id,
    String? name,
    Value<String?> taxId = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Supplier(
    id: id ?? this.id,
    name: name ?? this.name,
    taxId: taxId.present ? taxId.value : this.taxId,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    address: address.present ? address.value : this.address,
    notes: notes.present ? notes.value : this.notes,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Supplier copyWithCompanion(SuppliersCompanion data) {
    return Supplier(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      taxId: data.taxId.present ? data.taxId.value : this.taxId,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Supplier(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('taxId: $taxId, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    taxId,
    phone,
    email,
    address,
    notes,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Supplier &&
          other.id == this.id &&
          other.name == this.name &&
          other.taxId == this.taxId &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SuppliersCompanion extends UpdateCompanion<Supplier> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> taxId;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> address;
  final Value<String?> notes;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SuppliersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.taxId = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuppliersCompanion.insert({
    required String id,
    required String name,
    this.taxId = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Supplier> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? taxId,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (taxId != null) 'tax_id': taxId,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuppliersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? taxId,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? address,
    Value<String?>? notes,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SuppliersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      taxId: taxId ?? this.taxId,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (taxId.present) {
      map['tax_id'] = Variable<String>(taxId.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('taxId: $taxId, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExchangeRatesTable extends ExchangeRates
    with TableInfo<$ExchangeRatesTable, ExchangeRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExchangeRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES currencies (code)',
    ),
  );
  static const VerificationMeta _rateToBaseMeta = const VerificationMeta(
    'rateToBase',
  );
  @override
  late final GeneratedColumn<String> rateToBase = GeneratedColumn<String>(
    'rate_to_base',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveAtMeta = const VerificationMeta(
    'effectiveAt',
  );
  @override
  late final GeneratedColumn<DateTime> effectiveAt = GeneratedColumn<DateTime>(
    'effective_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByUserIdMeta = const VerificationMeta(
    'createdByUserId',
  );
  @override
  late final GeneratedColumn<String> createdByUserId = GeneratedColumn<String>(
    'created_by_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currencyCode,
    rateToBase,
    effectiveAt,
    createdByUserId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exchange_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExchangeRate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('rate_to_base')) {
      context.handle(
        _rateToBaseMeta,
        rateToBase.isAcceptableOrUnknown(
          data['rate_to_base']!,
          _rateToBaseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rateToBaseMeta);
    }
    if (data.containsKey('effective_at')) {
      context.handle(
        _effectiveAtMeta,
        effectiveAt.isAcceptableOrUnknown(
          data['effective_at']!,
          _effectiveAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveAtMeta);
    }
    if (data.containsKey('created_by_user_id')) {
      context.handle(
        _createdByUserIdMeta,
        createdByUserId.isAcceptableOrUnknown(
          data['created_by_user_id']!,
          _createdByUserIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExchangeRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExchangeRate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      rateToBase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rate_to_base'],
      )!,
      effectiveAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}effective_at'],
      )!,
      createdByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_user_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExchangeRatesTable createAlias(String alias) {
    return $ExchangeRatesTable(attachedDatabase, alias);
  }
}

class ExchangeRate extends DataClass implements Insertable<ExchangeRate> {
  final String id;
  final String currencyCode;
  final String rateToBase;
  final DateTime effectiveAt;
  final String? createdByUserId;
  final DateTime createdAt;
  const ExchangeRate({
    required this.id,
    required this.currencyCode,
    required this.rateToBase,
    required this.effectiveAt,
    this.createdByUserId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['currency_code'] = Variable<String>(currencyCode);
    map['rate_to_base'] = Variable<String>(rateToBase);
    map['effective_at'] = Variable<DateTime>(effectiveAt);
    if (!nullToAbsent || createdByUserId != null) {
      map['created_by_user_id'] = Variable<String>(createdByUserId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExchangeRatesCompanion toCompanion(bool nullToAbsent) {
    return ExchangeRatesCompanion(
      id: Value(id),
      currencyCode: Value(currencyCode),
      rateToBase: Value(rateToBase),
      effectiveAt: Value(effectiveAt),
      createdByUserId: createdByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(createdByUserId),
      createdAt: Value(createdAt),
    );
  }

  factory ExchangeRate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExchangeRate(
      id: serializer.fromJson<String>(json['id']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      rateToBase: serializer.fromJson<String>(json['rateToBase']),
      effectiveAt: serializer.fromJson<DateTime>(json['effectiveAt']),
      createdByUserId: serializer.fromJson<String?>(json['createdByUserId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'rateToBase': serializer.toJson<String>(rateToBase),
      'effectiveAt': serializer.toJson<DateTime>(effectiveAt),
      'createdByUserId': serializer.toJson<String?>(createdByUserId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ExchangeRate copyWith({
    String? id,
    String? currencyCode,
    String? rateToBase,
    DateTime? effectiveAt,
    Value<String?> createdByUserId = const Value.absent(),
    DateTime? createdAt,
  }) => ExchangeRate(
    id: id ?? this.id,
    currencyCode: currencyCode ?? this.currencyCode,
    rateToBase: rateToBase ?? this.rateToBase,
    effectiveAt: effectiveAt ?? this.effectiveAt,
    createdByUserId: createdByUserId.present
        ? createdByUserId.value
        : this.createdByUserId,
    createdAt: createdAt ?? this.createdAt,
  );
  ExchangeRate copyWithCompanion(ExchangeRatesCompanion data) {
    return ExchangeRate(
      id: data.id.present ? data.id.value : this.id,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      rateToBase: data.rateToBase.present
          ? data.rateToBase.value
          : this.rateToBase,
      effectiveAt: data.effectiveAt.present
          ? data.effectiveAt.value
          : this.effectiveAt,
      createdByUserId: data.createdByUserId.present
          ? data.createdByUserId.value
          : this.createdByUserId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRate(')
          ..write('id: $id, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('rateToBase: $rateToBase, ')
          ..write('effectiveAt: $effectiveAt, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    currencyCode,
    rateToBase,
    effectiveAt,
    createdByUserId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExchangeRate &&
          other.id == this.id &&
          other.currencyCode == this.currencyCode &&
          other.rateToBase == this.rateToBase &&
          other.effectiveAt == this.effectiveAt &&
          other.createdByUserId == this.createdByUserId &&
          other.createdAt == this.createdAt);
}

class ExchangeRatesCompanion extends UpdateCompanion<ExchangeRate> {
  final Value<String> id;
  final Value<String> currencyCode;
  final Value<String> rateToBase;
  final Value<DateTime> effectiveAt;
  final Value<String?> createdByUserId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ExchangeRatesCompanion({
    this.id = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.rateToBase = const Value.absent(),
    this.effectiveAt = const Value.absent(),
    this.createdByUserId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExchangeRatesCompanion.insert({
    required String id,
    required String currencyCode,
    required String rateToBase,
    required DateTime effectiveAt,
    this.createdByUserId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       currencyCode = Value(currencyCode),
       rateToBase = Value(rateToBase),
       effectiveAt = Value(effectiveAt);
  static Insertable<ExchangeRate> custom({
    Expression<String>? id,
    Expression<String>? currencyCode,
    Expression<String>? rateToBase,
    Expression<DateTime>? effectiveAt,
    Expression<String>? createdByUserId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (rateToBase != null) 'rate_to_base': rateToBase,
      if (effectiveAt != null) 'effective_at': effectiveAt,
      if (createdByUserId != null) 'created_by_user_id': createdByUserId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExchangeRatesCompanion copyWith({
    Value<String>? id,
    Value<String>? currencyCode,
    Value<String>? rateToBase,
    Value<DateTime>? effectiveAt,
    Value<String?>? createdByUserId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ExchangeRatesCompanion(
      id: id ?? this.id,
      currencyCode: currencyCode ?? this.currencyCode,
      rateToBase: rateToBase ?? this.rateToBase,
      effectiveAt: effectiveAt ?? this.effectiveAt,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (rateToBase.present) {
      map['rate_to_base'] = Variable<String>(rateToBase.value);
    }
    if (effectiveAt.present) {
      map['effective_at'] = Variable<DateTime>(effectiveAt.value);
    }
    if (createdByUserId.present) {
      map['created_by_user_id'] = Variable<String>(createdByUserId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRatesCompanion(')
          ..write('id: $id, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('rateToBase: $rateToBase, ')
          ..write('effectiveAt: $effectiveAt, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchasesTable extends Purchases
    with TableInfo<$PurchasesTable, Purchase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES suppliers (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _documentNumberMeta = const VerificationMeta(
    'documentNumber',
  );
  @override
  late final GeneratedColumn<String> documentNumber = GeneratedColumn<String>(
    'document_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
    'purchase_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES currencies (code)',
    ),
  );
  static const VerificationMeta _exchangeRateToBaseSnapshotMeta =
      const VerificationMeta('exchangeRateToBaseSnapshot');
  @override
  late final GeneratedColumn<String> exchangeRateToBaseSnapshot =
      GeneratedColumn<String>(
        'exchange_rate_to_base_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _subtotalMinorUnitsMeta =
      const VerificationMeta('subtotalMinorUnits');
  @override
  late final GeneratedColumn<int> subtotalMinorUnits = GeneratedColumn<int>(
    'subtotal_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountMinorUnitsMeta =
      const VerificationMeta('discountMinorUnits');
  @override
  late final GeneratedColumn<int> discountMinorUnits = GeneratedColumn<int>(
    'discount_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _taxMinorUnitsMeta = const VerificationMeta(
    'taxMinorUnits',
  );
  @override
  late final GeneratedColumn<int> taxMinorUnits = GeneratedColumn<int>(
    'tax_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalMinorUnitsMeta = const VerificationMeta(
    'totalMinorUnits',
  );
  @override
  late final GeneratedColumn<int> totalMinorUnits = GeneratedColumn<int>(
    'total_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _confirmedAtMeta = const VerificationMeta(
    'confirmedAt',
  );
  @override
  late final GeneratedColumn<DateTime> confirmedAt = GeneratedColumn<DateTime>(
    'confirmed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancelledAtMeta = const VerificationMeta(
    'cancelledAt',
  );
  @override
  late final GeneratedColumn<DateTime> cancelledAt = GeneratedColumn<DateTime>(
    'cancelled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancellationReasonMeta =
      const VerificationMeta('cancellationReason');
  @override
  late final GeneratedColumn<String> cancellationReason =
      GeneratedColumn<String>(
        'cancellation_reason',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    supplierId,
    documentNumber,
    purchaseDate,
    currencyCode,
    exchangeRateToBaseSnapshot,
    subtotalMinorUnits,
    discountMinorUnits,
    taxMinorUnits,
    totalMinorUnits,
    notes,
    status,
    confirmedAt,
    cancelledAt,
    cancellationReason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchases';
  @override
  VerificationContext validateIntegrity(
    Insertable<Purchase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('document_number')) {
      context.handle(
        _documentNumberMeta,
        documentNumber.isAcceptableOrUnknown(
          data['document_number']!,
          _documentNumberMeta,
        ),
      );
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchaseDateMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('exchange_rate_to_base_snapshot')) {
      context.handle(
        _exchangeRateToBaseSnapshotMeta,
        exchangeRateToBaseSnapshot.isAcceptableOrUnknown(
          data['exchange_rate_to_base_snapshot']!,
          _exchangeRateToBaseSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exchangeRateToBaseSnapshotMeta);
    }
    if (data.containsKey('subtotal_minor_units')) {
      context.handle(
        _subtotalMinorUnitsMeta,
        subtotalMinorUnits.isAcceptableOrUnknown(
          data['subtotal_minor_units']!,
          _subtotalMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subtotalMinorUnitsMeta);
    }
    if (data.containsKey('discount_minor_units')) {
      context.handle(
        _discountMinorUnitsMeta,
        discountMinorUnits.isAcceptableOrUnknown(
          data['discount_minor_units']!,
          _discountMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('tax_minor_units')) {
      context.handle(
        _taxMinorUnitsMeta,
        taxMinorUnits.isAcceptableOrUnknown(
          data['tax_minor_units']!,
          _taxMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('total_minor_units')) {
      context.handle(
        _totalMinorUnitsMeta,
        totalMinorUnits.isAcceptableOrUnknown(
          data['total_minor_units']!,
          _totalMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalMinorUnitsMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('confirmed_at')) {
      context.handle(
        _confirmedAtMeta,
        confirmedAt.isAcceptableOrUnknown(
          data['confirmed_at']!,
          _confirmedAtMeta,
        ),
      );
    }
    if (data.containsKey('cancelled_at')) {
      context.handle(
        _cancelledAtMeta,
        cancelledAt.isAcceptableOrUnknown(
          data['cancelled_at']!,
          _cancelledAtMeta,
        ),
      );
    }
    if (data.containsKey('cancellation_reason')) {
      context.handle(
        _cancellationReasonMeta,
        cancellationReason.isAcceptableOrUnknown(
          data['cancellation_reason']!,
          _cancellationReasonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Purchase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Purchase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      )!,
      documentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_number'],
      ),
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchase_date'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      exchangeRateToBaseSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exchange_rate_to_base_snapshot'],
      )!,
      subtotalMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subtotal_minor_units'],
      )!,
      discountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_minor_units'],
      )!,
      taxMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tax_minor_units'],
      )!,
      totalMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_minor_units'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      confirmedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}confirmed_at'],
      ),
      cancelledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cancelled_at'],
      ),
      cancellationReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cancellation_reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PurchasesTable createAlias(String alias) {
    return $PurchasesTable(attachedDatabase, alias);
  }
}

class Purchase extends DataClass implements Insertable<Purchase> {
  final String id;
  final String supplierId;
  final String? documentNumber;
  final DateTime purchaseDate;
  final String currencyCode;

  /// En borradores es provisional.
  /// Al confirmar, se sustituye por el snapshot histórico definitivo.
  final String exchangeRateToBaseSnapshot;
  final int subtotalMinorUnits;
  final int discountMinorUnits;
  final int taxMinorUnits;
  final int totalMinorUnits;
  final String? notes;

  /// Estados permitidos: draft, confirmed, cancelled.
  final String status;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime createdAt;
  const Purchase({
    required this.id,
    required this.supplierId,
    this.documentNumber,
    required this.purchaseDate,
    required this.currencyCode,
    required this.exchangeRateToBaseSnapshot,
    required this.subtotalMinorUnits,
    required this.discountMinorUnits,
    required this.taxMinorUnits,
    required this.totalMinorUnits,
    this.notes,
    required this.status,
    this.confirmedAt,
    this.cancelledAt,
    this.cancellationReason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['supplier_id'] = Variable<String>(supplierId);
    if (!nullToAbsent || documentNumber != null) {
      map['document_number'] = Variable<String>(documentNumber);
    }
    map['purchase_date'] = Variable<DateTime>(purchaseDate);
    map['currency_code'] = Variable<String>(currencyCode);
    map['exchange_rate_to_base_snapshot'] = Variable<String>(
      exchangeRateToBaseSnapshot,
    );
    map['subtotal_minor_units'] = Variable<int>(subtotalMinorUnits);
    map['discount_minor_units'] = Variable<int>(discountMinorUnits);
    map['tax_minor_units'] = Variable<int>(taxMinorUnits);
    map['total_minor_units'] = Variable<int>(totalMinorUnits);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || confirmedAt != null) {
      map['confirmed_at'] = Variable<DateTime>(confirmedAt);
    }
    if (!nullToAbsent || cancelledAt != null) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt);
    }
    if (!nullToAbsent || cancellationReason != null) {
      map['cancellation_reason'] = Variable<String>(cancellationReason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PurchasesCompanion toCompanion(bool nullToAbsent) {
    return PurchasesCompanion(
      id: Value(id),
      supplierId: Value(supplierId),
      documentNumber: documentNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(documentNumber),
      purchaseDate: Value(purchaseDate),
      currencyCode: Value(currencyCode),
      exchangeRateToBaseSnapshot: Value(exchangeRateToBaseSnapshot),
      subtotalMinorUnits: Value(subtotalMinorUnits),
      discountMinorUnits: Value(discountMinorUnits),
      taxMinorUnits: Value(taxMinorUnits),
      totalMinorUnits: Value(totalMinorUnits),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      status: Value(status),
      confirmedAt: confirmedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(confirmedAt),
      cancelledAt: cancelledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelledAt),
      cancellationReason: cancellationReason == null && nullToAbsent
          ? const Value.absent()
          : Value(cancellationReason),
      createdAt: Value(createdAt),
    );
  }

  factory Purchase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Purchase(
      id: serializer.fromJson<String>(json['id']),
      supplierId: serializer.fromJson<String>(json['supplierId']),
      documentNumber: serializer.fromJson<String?>(json['documentNumber']),
      purchaseDate: serializer.fromJson<DateTime>(json['purchaseDate']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      exchangeRateToBaseSnapshot: serializer.fromJson<String>(
        json['exchangeRateToBaseSnapshot'],
      ),
      subtotalMinorUnits: serializer.fromJson<int>(json['subtotalMinorUnits']),
      discountMinorUnits: serializer.fromJson<int>(json['discountMinorUnits']),
      taxMinorUnits: serializer.fromJson<int>(json['taxMinorUnits']),
      totalMinorUnits: serializer.fromJson<int>(json['totalMinorUnits']),
      notes: serializer.fromJson<String?>(json['notes']),
      status: serializer.fromJson<String>(json['status']),
      confirmedAt: serializer.fromJson<DateTime?>(json['confirmedAt']),
      cancelledAt: serializer.fromJson<DateTime?>(json['cancelledAt']),
      cancellationReason: serializer.fromJson<String?>(
        json['cancellationReason'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'supplierId': serializer.toJson<String>(supplierId),
      'documentNumber': serializer.toJson<String?>(documentNumber),
      'purchaseDate': serializer.toJson<DateTime>(purchaseDate),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'exchangeRateToBaseSnapshot': serializer.toJson<String>(
        exchangeRateToBaseSnapshot,
      ),
      'subtotalMinorUnits': serializer.toJson<int>(subtotalMinorUnits),
      'discountMinorUnits': serializer.toJson<int>(discountMinorUnits),
      'taxMinorUnits': serializer.toJson<int>(taxMinorUnits),
      'totalMinorUnits': serializer.toJson<int>(totalMinorUnits),
      'notes': serializer.toJson<String?>(notes),
      'status': serializer.toJson<String>(status),
      'confirmedAt': serializer.toJson<DateTime?>(confirmedAt),
      'cancelledAt': serializer.toJson<DateTime?>(cancelledAt),
      'cancellationReason': serializer.toJson<String?>(cancellationReason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Purchase copyWith({
    String? id,
    String? supplierId,
    Value<String?> documentNumber = const Value.absent(),
    DateTime? purchaseDate,
    String? currencyCode,
    String? exchangeRateToBaseSnapshot,
    int? subtotalMinorUnits,
    int? discountMinorUnits,
    int? taxMinorUnits,
    int? totalMinorUnits,
    Value<String?> notes = const Value.absent(),
    String? status,
    Value<DateTime?> confirmedAt = const Value.absent(),
    Value<DateTime?> cancelledAt = const Value.absent(),
    Value<String?> cancellationReason = const Value.absent(),
    DateTime? createdAt,
  }) => Purchase(
    id: id ?? this.id,
    supplierId: supplierId ?? this.supplierId,
    documentNumber: documentNumber.present
        ? documentNumber.value
        : this.documentNumber,
    purchaseDate: purchaseDate ?? this.purchaseDate,
    currencyCode: currencyCode ?? this.currencyCode,
    exchangeRateToBaseSnapshot:
        exchangeRateToBaseSnapshot ?? this.exchangeRateToBaseSnapshot,
    subtotalMinorUnits: subtotalMinorUnits ?? this.subtotalMinorUnits,
    discountMinorUnits: discountMinorUnits ?? this.discountMinorUnits,
    taxMinorUnits: taxMinorUnits ?? this.taxMinorUnits,
    totalMinorUnits: totalMinorUnits ?? this.totalMinorUnits,
    notes: notes.present ? notes.value : this.notes,
    status: status ?? this.status,
    confirmedAt: confirmedAt.present ? confirmedAt.value : this.confirmedAt,
    cancelledAt: cancelledAt.present ? cancelledAt.value : this.cancelledAt,
    cancellationReason: cancellationReason.present
        ? cancellationReason.value
        : this.cancellationReason,
    createdAt: createdAt ?? this.createdAt,
  );
  Purchase copyWithCompanion(PurchasesCompanion data) {
    return Purchase(
      id: data.id.present ? data.id.value : this.id,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      documentNumber: data.documentNumber.present
          ? data.documentNumber.value
          : this.documentNumber,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      exchangeRateToBaseSnapshot: data.exchangeRateToBaseSnapshot.present
          ? data.exchangeRateToBaseSnapshot.value
          : this.exchangeRateToBaseSnapshot,
      subtotalMinorUnits: data.subtotalMinorUnits.present
          ? data.subtotalMinorUnits.value
          : this.subtotalMinorUnits,
      discountMinorUnits: data.discountMinorUnits.present
          ? data.discountMinorUnits.value
          : this.discountMinorUnits,
      taxMinorUnits: data.taxMinorUnits.present
          ? data.taxMinorUnits.value
          : this.taxMinorUnits,
      totalMinorUnits: data.totalMinorUnits.present
          ? data.totalMinorUnits.value
          : this.totalMinorUnits,
      notes: data.notes.present ? data.notes.value : this.notes,
      status: data.status.present ? data.status.value : this.status,
      confirmedAt: data.confirmedAt.present
          ? data.confirmedAt.value
          : this.confirmedAt,
      cancelledAt: data.cancelledAt.present
          ? data.cancelledAt.value
          : this.cancelledAt,
      cancellationReason: data.cancellationReason.present
          ? data.cancellationReason.value
          : this.cancellationReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Purchase(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('documentNumber: $documentNumber, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('exchangeRateToBaseSnapshot: $exchangeRateToBaseSnapshot, ')
          ..write('subtotalMinorUnits: $subtotalMinorUnits, ')
          ..write('discountMinorUnits: $discountMinorUnits, ')
          ..write('taxMinorUnits: $taxMinorUnits, ')
          ..write('totalMinorUnits: $totalMinorUnits, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('cancellationReason: $cancellationReason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    supplierId,
    documentNumber,
    purchaseDate,
    currencyCode,
    exchangeRateToBaseSnapshot,
    subtotalMinorUnits,
    discountMinorUnits,
    taxMinorUnits,
    totalMinorUnits,
    notes,
    status,
    confirmedAt,
    cancelledAt,
    cancellationReason,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Purchase &&
          other.id == this.id &&
          other.supplierId == this.supplierId &&
          other.documentNumber == this.documentNumber &&
          other.purchaseDate == this.purchaseDate &&
          other.currencyCode == this.currencyCode &&
          other.exchangeRateToBaseSnapshot == this.exchangeRateToBaseSnapshot &&
          other.subtotalMinorUnits == this.subtotalMinorUnits &&
          other.discountMinorUnits == this.discountMinorUnits &&
          other.taxMinorUnits == this.taxMinorUnits &&
          other.totalMinorUnits == this.totalMinorUnits &&
          other.notes == this.notes &&
          other.status == this.status &&
          other.confirmedAt == this.confirmedAt &&
          other.cancelledAt == this.cancelledAt &&
          other.cancellationReason == this.cancellationReason &&
          other.createdAt == this.createdAt);
}

class PurchasesCompanion extends UpdateCompanion<Purchase> {
  final Value<String> id;
  final Value<String> supplierId;
  final Value<String?> documentNumber;
  final Value<DateTime> purchaseDate;
  final Value<String> currencyCode;
  final Value<String> exchangeRateToBaseSnapshot;
  final Value<int> subtotalMinorUnits;
  final Value<int> discountMinorUnits;
  final Value<int> taxMinorUnits;
  final Value<int> totalMinorUnits;
  final Value<String?> notes;
  final Value<String> status;
  final Value<DateTime?> confirmedAt;
  final Value<DateTime?> cancelledAt;
  final Value<String?> cancellationReason;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PurchasesCompanion({
    this.id = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.documentNumber = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.exchangeRateToBaseSnapshot = const Value.absent(),
    this.subtotalMinorUnits = const Value.absent(),
    this.discountMinorUnits = const Value.absent(),
    this.taxMinorUnits = const Value.absent(),
    this.totalMinorUnits = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.confirmedAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.cancellationReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchasesCompanion.insert({
    required String id,
    required String supplierId,
    this.documentNumber = const Value.absent(),
    required DateTime purchaseDate,
    required String currencyCode,
    required String exchangeRateToBaseSnapshot,
    required int subtotalMinorUnits,
    this.discountMinorUnits = const Value.absent(),
    this.taxMinorUnits = const Value.absent(),
    required int totalMinorUnits,
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.confirmedAt = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.cancellationReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       supplierId = Value(supplierId),
       purchaseDate = Value(purchaseDate),
       currencyCode = Value(currencyCode),
       exchangeRateToBaseSnapshot = Value(exchangeRateToBaseSnapshot),
       subtotalMinorUnits = Value(subtotalMinorUnits),
       totalMinorUnits = Value(totalMinorUnits);
  static Insertable<Purchase> custom({
    Expression<String>? id,
    Expression<String>? supplierId,
    Expression<String>? documentNumber,
    Expression<DateTime>? purchaseDate,
    Expression<String>? currencyCode,
    Expression<String>? exchangeRateToBaseSnapshot,
    Expression<int>? subtotalMinorUnits,
    Expression<int>? discountMinorUnits,
    Expression<int>? taxMinorUnits,
    Expression<int>? totalMinorUnits,
    Expression<String>? notes,
    Expression<String>? status,
    Expression<DateTime>? confirmedAt,
    Expression<DateTime>? cancelledAt,
    Expression<String>? cancellationReason,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supplierId != null) 'supplier_id': supplierId,
      if (documentNumber != null) 'document_number': documentNumber,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (exchangeRateToBaseSnapshot != null)
        'exchange_rate_to_base_snapshot': exchangeRateToBaseSnapshot,
      if (subtotalMinorUnits != null)
        'subtotal_minor_units': subtotalMinorUnits,
      if (discountMinorUnits != null)
        'discount_minor_units': discountMinorUnits,
      if (taxMinorUnits != null) 'tax_minor_units': taxMinorUnits,
      if (totalMinorUnits != null) 'total_minor_units': totalMinorUnits,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (confirmedAt != null) 'confirmed_at': confirmedAt,
      if (cancelledAt != null) 'cancelled_at': cancelledAt,
      if (cancellationReason != null) 'cancellation_reason': cancellationReason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchasesCompanion copyWith({
    Value<String>? id,
    Value<String>? supplierId,
    Value<String?>? documentNumber,
    Value<DateTime>? purchaseDate,
    Value<String>? currencyCode,
    Value<String>? exchangeRateToBaseSnapshot,
    Value<int>? subtotalMinorUnits,
    Value<int>? discountMinorUnits,
    Value<int>? taxMinorUnits,
    Value<int>? totalMinorUnits,
    Value<String?>? notes,
    Value<String>? status,
    Value<DateTime?>? confirmedAt,
    Value<DateTime?>? cancelledAt,
    Value<String?>? cancellationReason,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PurchasesCompanion(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      documentNumber: documentNumber ?? this.documentNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      currencyCode: currencyCode ?? this.currencyCode,
      exchangeRateToBaseSnapshot:
          exchangeRateToBaseSnapshot ?? this.exchangeRateToBaseSnapshot,
      subtotalMinorUnits: subtotalMinorUnits ?? this.subtotalMinorUnits,
      discountMinorUnits: discountMinorUnits ?? this.discountMinorUnits,
      taxMinorUnits: taxMinorUnits ?? this.taxMinorUnits,
      totalMinorUnits: totalMinorUnits ?? this.totalMinorUnits,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (documentNumber.present) {
      map['document_number'] = Variable<String>(documentNumber.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (exchangeRateToBaseSnapshot.present) {
      map['exchange_rate_to_base_snapshot'] = Variable<String>(
        exchangeRateToBaseSnapshot.value,
      );
    }
    if (subtotalMinorUnits.present) {
      map['subtotal_minor_units'] = Variable<int>(subtotalMinorUnits.value);
    }
    if (discountMinorUnits.present) {
      map['discount_minor_units'] = Variable<int>(discountMinorUnits.value);
    }
    if (taxMinorUnits.present) {
      map['tax_minor_units'] = Variable<int>(taxMinorUnits.value);
    }
    if (totalMinorUnits.present) {
      map['total_minor_units'] = Variable<int>(totalMinorUnits.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (confirmedAt.present) {
      map['confirmed_at'] = Variable<DateTime>(confirmedAt.value);
    }
    if (cancelledAt.present) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt.value);
    }
    if (cancellationReason.present) {
      map['cancellation_reason'] = Variable<String>(cancellationReason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchasesCompanion(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('documentNumber: $documentNumber, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('exchangeRateToBaseSnapshot: $exchangeRateToBaseSnapshot, ')
          ..write('subtotalMinorUnits: $subtotalMinorUnits, ')
          ..write('discountMinorUnits: $discountMinorUnits, ')
          ..write('taxMinorUnits: $taxMinorUnits, ')
          ..write('totalMinorUnits: $totalMinorUnits, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('cancellationReason: $cancellationReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseDetailsTable extends PurchaseDetails
    with TableInfo<$PurchaseDetailsTable, PurchaseDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseIdMeta = const VerificationMeta(
    'purchaseId',
  );
  @override
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
    'purchase_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES purchases (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _skuSnapshotMeta = const VerificationMeta(
    'skuSnapshot',
  );
  @override
  late final GeneratedColumn<String> skuSnapshot = GeneratedColumn<String>(
    'sku_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameSnapshotMeta =
      const VerificationMeta('productNameSnapshot');
  @override
  late final GeneratedColumn<String> productNameSnapshot =
      GeneratedColumn<String>(
        'product_name_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _unitSnapshotMeta = const VerificationMeta(
    'unitSnapshot',
  );
  @override
  late final GeneratedColumn<String> unitSnapshot = GeneratedColumn<String>(
    'unit_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMilliUnitsMeta =
      const VerificationMeta('quantityMilliUnits');
  @override
  late final GeneratedColumn<int> quantityMilliUnits = GeneratedColumn<int>(
    'quantity_milli_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCostMinorUnitsMeta =
      const VerificationMeta('unitCostMinorUnits');
  @override
  late final GeneratedColumn<int> unitCostMinorUnits = GeneratedColumn<int>(
    'unit_cost_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountMinorUnitsMeta =
      const VerificationMeta('discountMinorUnits');
  @override
  late final GeneratedColumn<int> discountMinorUnits = GeneratedColumn<int>(
    'discount_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discountTypeMeta = const VerificationMeta(
    'discountType',
  );
  @override
  late final GeneratedColumn<String> discountType = GeneratedColumn<String>(
    'discount_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('fixed'),
  );
  static const VerificationMeta _discountRateMeta = const VerificationMeta(
    'discountRate',
  );
  @override
  late final GeneratedColumn<String> discountRate = GeneratedColumn<String>(
    'discount_rate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxMinorUnitsMeta = const VerificationMeta(
    'taxMinorUnits',
  );
  @override
  late final GeneratedColumn<int> taxMinorUnits = GeneratedColumn<int>(
    'tax_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _taxTypeMeta = const VerificationMeta(
    'taxType',
  );
  @override
  late final GeneratedColumn<String> taxType = GeneratedColumn<String>(
    'tax_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('fixed'),
  );
  static const VerificationMeta _taxRateMeta = const VerificationMeta(
    'taxRate',
  );
  @override
  late final GeneratedColumn<String> taxRate = GeneratedColumn<String>(
    'tax_rate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalMinorUnitsMeta = const VerificationMeta(
    'totalMinorUnits',
  );
  @override
  late final GeneratedColumn<int> totalMinorUnits = GeneratedColumn<int>(
    'total_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    purchaseId,
    productId,
    skuSnapshot,
    productNameSnapshot,
    unitSnapshot,
    quantityMilliUnits,
    unitCostMinorUnits,
    discountMinorUnits,
    discountType,
    discountRate,
    taxMinorUnits,
    taxType,
    taxRate,
    totalMinorUnits,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_details';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseDetail> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('purchase_id')) {
      context.handle(
        _purchaseIdMeta,
        purchaseId.isAcceptableOrUnknown(data['purchase_id']!, _purchaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_purchaseIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('sku_snapshot')) {
      context.handle(
        _skuSnapshotMeta,
        skuSnapshot.isAcceptableOrUnknown(
          data['sku_snapshot']!,
          _skuSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_skuSnapshotMeta);
    }
    if (data.containsKey('product_name_snapshot')) {
      context.handle(
        _productNameSnapshotMeta,
        productNameSnapshot.isAcceptableOrUnknown(
          data['product_name_snapshot']!,
          _productNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameSnapshotMeta);
    }
    if (data.containsKey('unit_snapshot')) {
      context.handle(
        _unitSnapshotMeta,
        unitSnapshot.isAcceptableOrUnknown(
          data['unit_snapshot']!,
          _unitSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitSnapshotMeta);
    }
    if (data.containsKey('quantity_milli_units')) {
      context.handle(
        _quantityMilliUnitsMeta,
        quantityMilliUnits.isAcceptableOrUnknown(
          data['quantity_milli_units']!,
          _quantityMilliUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityMilliUnitsMeta);
    }
    if (data.containsKey('unit_cost_minor_units')) {
      context.handle(
        _unitCostMinorUnitsMeta,
        unitCostMinorUnits.isAcceptableOrUnknown(
          data['unit_cost_minor_units']!,
          _unitCostMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitCostMinorUnitsMeta);
    }
    if (data.containsKey('discount_minor_units')) {
      context.handle(
        _discountMinorUnitsMeta,
        discountMinorUnits.isAcceptableOrUnknown(
          data['discount_minor_units']!,
          _discountMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('discount_type')) {
      context.handle(
        _discountTypeMeta,
        discountType.isAcceptableOrUnknown(
          data['discount_type']!,
          _discountTypeMeta,
        ),
      );
    }
    if (data.containsKey('discount_rate')) {
      context.handle(
        _discountRateMeta,
        discountRate.isAcceptableOrUnknown(
          data['discount_rate']!,
          _discountRateMeta,
        ),
      );
    }
    if (data.containsKey('tax_minor_units')) {
      context.handle(
        _taxMinorUnitsMeta,
        taxMinorUnits.isAcceptableOrUnknown(
          data['tax_minor_units']!,
          _taxMinorUnitsMeta,
        ),
      );
    }
    if (data.containsKey('tax_type')) {
      context.handle(
        _taxTypeMeta,
        taxType.isAcceptableOrUnknown(data['tax_type']!, _taxTypeMeta),
      );
    }
    if (data.containsKey('tax_rate')) {
      context.handle(
        _taxRateMeta,
        taxRate.isAcceptableOrUnknown(data['tax_rate']!, _taxRateMeta),
      );
    }
    if (data.containsKey('total_minor_units')) {
      context.handle(
        _totalMinorUnitsMeta,
        totalMinorUnits.isAcceptableOrUnknown(
          data['total_minor_units']!,
          _totalMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalMinorUnitsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseDetail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseDetail(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      purchaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      skuSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku_snapshot'],
      )!,
      productNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name_snapshot'],
      )!,
      unitSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_snapshot'],
      )!,
      quantityMilliUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_milli_units'],
      )!,
      unitCostMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_cost_minor_units'],
      )!,
      discountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_minor_units'],
      )!,
      discountType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discount_type'],
      )!,
      discountRate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discount_rate'],
      ),
      taxMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tax_minor_units'],
      )!,
      taxType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tax_type'],
      )!,
      taxRate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tax_rate'],
      ),
      totalMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_minor_units'],
      )!,
    );
  }

  @override
  $PurchaseDetailsTable createAlias(String alias) {
    return $PurchaseDetailsTable(attachedDatabase, alias);
  }
}

class PurchaseDetail extends DataClass implements Insertable<PurchaseDetail> {
  final String id;
  final String purchaseId;
  final String productId;

  /// Datos históricos del producto al registrar la compra.
  final String skuSnapshot;
  final String productNameSnapshot;
  final String unitSnapshot;
  final int quantityMilliUnits;
  final int unitCostMinorUnits;
  final int discountMinorUnits;

  /// Forma en que se calculó el descuento.
  /// Valores permitidos: fixed, percentage.
  final String discountType;

  /// Porcentaje original del descuento, almacenado como decimal textual.
  /// Nulo cuando el descuento fue fijo.
  final String? discountRate;
  final int taxMinorUnits;

  /// Forma en que se calculó el impuesto.
  /// Valores permitidos: fixed, percentage.
  final String taxType;

  /// Porcentaje original del impuesto, almacenado como decimal textual.
  /// Nulo cuando el impuesto fue fijo.
  final String? taxRate;
  final int totalMinorUnits;
  const PurchaseDetail({
    required this.id,
    required this.purchaseId,
    required this.productId,
    required this.skuSnapshot,
    required this.productNameSnapshot,
    required this.unitSnapshot,
    required this.quantityMilliUnits,
    required this.unitCostMinorUnits,
    required this.discountMinorUnits,
    required this.discountType,
    this.discountRate,
    required this.taxMinorUnits,
    required this.taxType,
    this.taxRate,
    required this.totalMinorUnits,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['purchase_id'] = Variable<String>(purchaseId);
    map['product_id'] = Variable<String>(productId);
    map['sku_snapshot'] = Variable<String>(skuSnapshot);
    map['product_name_snapshot'] = Variable<String>(productNameSnapshot);
    map['unit_snapshot'] = Variable<String>(unitSnapshot);
    map['quantity_milli_units'] = Variable<int>(quantityMilliUnits);
    map['unit_cost_minor_units'] = Variable<int>(unitCostMinorUnits);
    map['discount_minor_units'] = Variable<int>(discountMinorUnits);
    map['discount_type'] = Variable<String>(discountType);
    if (!nullToAbsent || discountRate != null) {
      map['discount_rate'] = Variable<String>(discountRate);
    }
    map['tax_minor_units'] = Variable<int>(taxMinorUnits);
    map['tax_type'] = Variable<String>(taxType);
    if (!nullToAbsent || taxRate != null) {
      map['tax_rate'] = Variable<String>(taxRate);
    }
    map['total_minor_units'] = Variable<int>(totalMinorUnits);
    return map;
  }

  PurchaseDetailsCompanion toCompanion(bool nullToAbsent) {
    return PurchaseDetailsCompanion(
      id: Value(id),
      purchaseId: Value(purchaseId),
      productId: Value(productId),
      skuSnapshot: Value(skuSnapshot),
      productNameSnapshot: Value(productNameSnapshot),
      unitSnapshot: Value(unitSnapshot),
      quantityMilliUnits: Value(quantityMilliUnits),
      unitCostMinorUnits: Value(unitCostMinorUnits),
      discountMinorUnits: Value(discountMinorUnits),
      discountType: Value(discountType),
      discountRate: discountRate == null && nullToAbsent
          ? const Value.absent()
          : Value(discountRate),
      taxMinorUnits: Value(taxMinorUnits),
      taxType: Value(taxType),
      taxRate: taxRate == null && nullToAbsent
          ? const Value.absent()
          : Value(taxRate),
      totalMinorUnits: Value(totalMinorUnits),
    );
  }

  factory PurchaseDetail.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseDetail(
      id: serializer.fromJson<String>(json['id']),
      purchaseId: serializer.fromJson<String>(json['purchaseId']),
      productId: serializer.fromJson<String>(json['productId']),
      skuSnapshot: serializer.fromJson<String>(json['skuSnapshot']),
      productNameSnapshot: serializer.fromJson<String>(
        json['productNameSnapshot'],
      ),
      unitSnapshot: serializer.fromJson<String>(json['unitSnapshot']),
      quantityMilliUnits: serializer.fromJson<int>(json['quantityMilliUnits']),
      unitCostMinorUnits: serializer.fromJson<int>(json['unitCostMinorUnits']),
      discountMinorUnits: serializer.fromJson<int>(json['discountMinorUnits']),
      discountType: serializer.fromJson<String>(json['discountType']),
      discountRate: serializer.fromJson<String?>(json['discountRate']),
      taxMinorUnits: serializer.fromJson<int>(json['taxMinorUnits']),
      taxType: serializer.fromJson<String>(json['taxType']),
      taxRate: serializer.fromJson<String?>(json['taxRate']),
      totalMinorUnits: serializer.fromJson<int>(json['totalMinorUnits']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'purchaseId': serializer.toJson<String>(purchaseId),
      'productId': serializer.toJson<String>(productId),
      'skuSnapshot': serializer.toJson<String>(skuSnapshot),
      'productNameSnapshot': serializer.toJson<String>(productNameSnapshot),
      'unitSnapshot': serializer.toJson<String>(unitSnapshot),
      'quantityMilliUnits': serializer.toJson<int>(quantityMilliUnits),
      'unitCostMinorUnits': serializer.toJson<int>(unitCostMinorUnits),
      'discountMinorUnits': serializer.toJson<int>(discountMinorUnits),
      'discountType': serializer.toJson<String>(discountType),
      'discountRate': serializer.toJson<String?>(discountRate),
      'taxMinorUnits': serializer.toJson<int>(taxMinorUnits),
      'taxType': serializer.toJson<String>(taxType),
      'taxRate': serializer.toJson<String?>(taxRate),
      'totalMinorUnits': serializer.toJson<int>(totalMinorUnits),
    };
  }

  PurchaseDetail copyWith({
    String? id,
    String? purchaseId,
    String? productId,
    String? skuSnapshot,
    String? productNameSnapshot,
    String? unitSnapshot,
    int? quantityMilliUnits,
    int? unitCostMinorUnits,
    int? discountMinorUnits,
    String? discountType,
    Value<String?> discountRate = const Value.absent(),
    int? taxMinorUnits,
    String? taxType,
    Value<String?> taxRate = const Value.absent(),
    int? totalMinorUnits,
  }) => PurchaseDetail(
    id: id ?? this.id,
    purchaseId: purchaseId ?? this.purchaseId,
    productId: productId ?? this.productId,
    skuSnapshot: skuSnapshot ?? this.skuSnapshot,
    productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
    unitSnapshot: unitSnapshot ?? this.unitSnapshot,
    quantityMilliUnits: quantityMilliUnits ?? this.quantityMilliUnits,
    unitCostMinorUnits: unitCostMinorUnits ?? this.unitCostMinorUnits,
    discountMinorUnits: discountMinorUnits ?? this.discountMinorUnits,
    discountType: discountType ?? this.discountType,
    discountRate: discountRate.present ? discountRate.value : this.discountRate,
    taxMinorUnits: taxMinorUnits ?? this.taxMinorUnits,
    taxType: taxType ?? this.taxType,
    taxRate: taxRate.present ? taxRate.value : this.taxRate,
    totalMinorUnits: totalMinorUnits ?? this.totalMinorUnits,
  );
  PurchaseDetail copyWithCompanion(PurchaseDetailsCompanion data) {
    return PurchaseDetail(
      id: data.id.present ? data.id.value : this.id,
      purchaseId: data.purchaseId.present
          ? data.purchaseId.value
          : this.purchaseId,
      productId: data.productId.present ? data.productId.value : this.productId,
      skuSnapshot: data.skuSnapshot.present
          ? data.skuSnapshot.value
          : this.skuSnapshot,
      productNameSnapshot: data.productNameSnapshot.present
          ? data.productNameSnapshot.value
          : this.productNameSnapshot,
      unitSnapshot: data.unitSnapshot.present
          ? data.unitSnapshot.value
          : this.unitSnapshot,
      quantityMilliUnits: data.quantityMilliUnits.present
          ? data.quantityMilliUnits.value
          : this.quantityMilliUnits,
      unitCostMinorUnits: data.unitCostMinorUnits.present
          ? data.unitCostMinorUnits.value
          : this.unitCostMinorUnits,
      discountMinorUnits: data.discountMinorUnits.present
          ? data.discountMinorUnits.value
          : this.discountMinorUnits,
      discountType: data.discountType.present
          ? data.discountType.value
          : this.discountType,
      discountRate: data.discountRate.present
          ? data.discountRate.value
          : this.discountRate,
      taxMinorUnits: data.taxMinorUnits.present
          ? data.taxMinorUnits.value
          : this.taxMinorUnits,
      taxType: data.taxType.present ? data.taxType.value : this.taxType,
      taxRate: data.taxRate.present ? data.taxRate.value : this.taxRate,
      totalMinorUnits: data.totalMinorUnits.present
          ? data.totalMinorUnits.value
          : this.totalMinorUnits,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseDetail(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('productId: $productId, ')
          ..write('skuSnapshot: $skuSnapshot, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('unitSnapshot: $unitSnapshot, ')
          ..write('quantityMilliUnits: $quantityMilliUnits, ')
          ..write('unitCostMinorUnits: $unitCostMinorUnits, ')
          ..write('discountMinorUnits: $discountMinorUnits, ')
          ..write('discountType: $discountType, ')
          ..write('discountRate: $discountRate, ')
          ..write('taxMinorUnits: $taxMinorUnits, ')
          ..write('taxType: $taxType, ')
          ..write('taxRate: $taxRate, ')
          ..write('totalMinorUnits: $totalMinorUnits')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    purchaseId,
    productId,
    skuSnapshot,
    productNameSnapshot,
    unitSnapshot,
    quantityMilliUnits,
    unitCostMinorUnits,
    discountMinorUnits,
    discountType,
    discountRate,
    taxMinorUnits,
    taxType,
    taxRate,
    totalMinorUnits,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseDetail &&
          other.id == this.id &&
          other.purchaseId == this.purchaseId &&
          other.productId == this.productId &&
          other.skuSnapshot == this.skuSnapshot &&
          other.productNameSnapshot == this.productNameSnapshot &&
          other.unitSnapshot == this.unitSnapshot &&
          other.quantityMilliUnits == this.quantityMilliUnits &&
          other.unitCostMinorUnits == this.unitCostMinorUnits &&
          other.discountMinorUnits == this.discountMinorUnits &&
          other.discountType == this.discountType &&
          other.discountRate == this.discountRate &&
          other.taxMinorUnits == this.taxMinorUnits &&
          other.taxType == this.taxType &&
          other.taxRate == this.taxRate &&
          other.totalMinorUnits == this.totalMinorUnits);
}

class PurchaseDetailsCompanion extends UpdateCompanion<PurchaseDetail> {
  final Value<String> id;
  final Value<String> purchaseId;
  final Value<String> productId;
  final Value<String> skuSnapshot;
  final Value<String> productNameSnapshot;
  final Value<String> unitSnapshot;
  final Value<int> quantityMilliUnits;
  final Value<int> unitCostMinorUnits;
  final Value<int> discountMinorUnits;
  final Value<String> discountType;
  final Value<String?> discountRate;
  final Value<int> taxMinorUnits;
  final Value<String> taxType;
  final Value<String?> taxRate;
  final Value<int> totalMinorUnits;
  final Value<int> rowid;
  const PurchaseDetailsCompanion({
    this.id = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.productId = const Value.absent(),
    this.skuSnapshot = const Value.absent(),
    this.productNameSnapshot = const Value.absent(),
    this.unitSnapshot = const Value.absent(),
    this.quantityMilliUnits = const Value.absent(),
    this.unitCostMinorUnits = const Value.absent(),
    this.discountMinorUnits = const Value.absent(),
    this.discountType = const Value.absent(),
    this.discountRate = const Value.absent(),
    this.taxMinorUnits = const Value.absent(),
    this.taxType = const Value.absent(),
    this.taxRate = const Value.absent(),
    this.totalMinorUnits = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseDetailsCompanion.insert({
    required String id,
    required String purchaseId,
    required String productId,
    required String skuSnapshot,
    required String productNameSnapshot,
    required String unitSnapshot,
    required int quantityMilliUnits,
    required int unitCostMinorUnits,
    this.discountMinorUnits = const Value.absent(),
    this.discountType = const Value.absent(),
    this.discountRate = const Value.absent(),
    this.taxMinorUnits = const Value.absent(),
    this.taxType = const Value.absent(),
    this.taxRate = const Value.absent(),
    required int totalMinorUnits,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       purchaseId = Value(purchaseId),
       productId = Value(productId),
       skuSnapshot = Value(skuSnapshot),
       productNameSnapshot = Value(productNameSnapshot),
       unitSnapshot = Value(unitSnapshot),
       quantityMilliUnits = Value(quantityMilliUnits),
       unitCostMinorUnits = Value(unitCostMinorUnits),
       totalMinorUnits = Value(totalMinorUnits);
  static Insertable<PurchaseDetail> custom({
    Expression<String>? id,
    Expression<String>? purchaseId,
    Expression<String>? productId,
    Expression<String>? skuSnapshot,
    Expression<String>? productNameSnapshot,
    Expression<String>? unitSnapshot,
    Expression<int>? quantityMilliUnits,
    Expression<int>? unitCostMinorUnits,
    Expression<int>? discountMinorUnits,
    Expression<String>? discountType,
    Expression<String>? discountRate,
    Expression<int>? taxMinorUnits,
    Expression<String>? taxType,
    Expression<String>? taxRate,
    Expression<int>? totalMinorUnits,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (productId != null) 'product_id': productId,
      if (skuSnapshot != null) 'sku_snapshot': skuSnapshot,
      if (productNameSnapshot != null)
        'product_name_snapshot': productNameSnapshot,
      if (unitSnapshot != null) 'unit_snapshot': unitSnapshot,
      if (quantityMilliUnits != null)
        'quantity_milli_units': quantityMilliUnits,
      if (unitCostMinorUnits != null)
        'unit_cost_minor_units': unitCostMinorUnits,
      if (discountMinorUnits != null)
        'discount_minor_units': discountMinorUnits,
      if (discountType != null) 'discount_type': discountType,
      if (discountRate != null) 'discount_rate': discountRate,
      if (taxMinorUnits != null) 'tax_minor_units': taxMinorUnits,
      if (taxType != null) 'tax_type': taxType,
      if (taxRate != null) 'tax_rate': taxRate,
      if (totalMinorUnits != null) 'total_minor_units': totalMinorUnits,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseDetailsCompanion copyWith({
    Value<String>? id,
    Value<String>? purchaseId,
    Value<String>? productId,
    Value<String>? skuSnapshot,
    Value<String>? productNameSnapshot,
    Value<String>? unitSnapshot,
    Value<int>? quantityMilliUnits,
    Value<int>? unitCostMinorUnits,
    Value<int>? discountMinorUnits,
    Value<String>? discountType,
    Value<String?>? discountRate,
    Value<int>? taxMinorUnits,
    Value<String>? taxType,
    Value<String?>? taxRate,
    Value<int>? totalMinorUnits,
    Value<int>? rowid,
  }) {
    return PurchaseDetailsCompanion(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      productId: productId ?? this.productId,
      skuSnapshot: skuSnapshot ?? this.skuSnapshot,
      productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
      unitSnapshot: unitSnapshot ?? this.unitSnapshot,
      quantityMilliUnits: quantityMilliUnits ?? this.quantityMilliUnits,
      unitCostMinorUnits: unitCostMinorUnits ?? this.unitCostMinorUnits,
      discountMinorUnits: discountMinorUnits ?? this.discountMinorUnits,
      discountType: discountType ?? this.discountType,
      discountRate: discountRate ?? this.discountRate,
      taxMinorUnits: taxMinorUnits ?? this.taxMinorUnits,
      taxType: taxType ?? this.taxType,
      taxRate: taxRate ?? this.taxRate,
      totalMinorUnits: totalMinorUnits ?? this.totalMinorUnits,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (skuSnapshot.present) {
      map['sku_snapshot'] = Variable<String>(skuSnapshot.value);
    }
    if (productNameSnapshot.present) {
      map['product_name_snapshot'] = Variable<String>(
        productNameSnapshot.value,
      );
    }
    if (unitSnapshot.present) {
      map['unit_snapshot'] = Variable<String>(unitSnapshot.value);
    }
    if (quantityMilliUnits.present) {
      map['quantity_milli_units'] = Variable<int>(quantityMilliUnits.value);
    }
    if (unitCostMinorUnits.present) {
      map['unit_cost_minor_units'] = Variable<int>(unitCostMinorUnits.value);
    }
    if (discountMinorUnits.present) {
      map['discount_minor_units'] = Variable<int>(discountMinorUnits.value);
    }
    if (discountType.present) {
      map['discount_type'] = Variable<String>(discountType.value);
    }
    if (discountRate.present) {
      map['discount_rate'] = Variable<String>(discountRate.value);
    }
    if (taxMinorUnits.present) {
      map['tax_minor_units'] = Variable<int>(taxMinorUnits.value);
    }
    if (taxType.present) {
      map['tax_type'] = Variable<String>(taxType.value);
    }
    if (taxRate.present) {
      map['tax_rate'] = Variable<String>(taxRate.value);
    }
    if (totalMinorUnits.present) {
      map['total_minor_units'] = Variable<int>(totalMinorUnits.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseDetailsCompanion(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('productId: $productId, ')
          ..write('skuSnapshot: $skuSnapshot, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('unitSnapshot: $unitSnapshot, ')
          ..write('quantityMilliUnits: $quantityMilliUnits, ')
          ..write('unitCostMinorUnits: $unitCostMinorUnits, ')
          ..write('discountMinorUnits: $discountMinorUnits, ')
          ..write('discountType: $discountType, ')
          ..write('discountRate: $discountRate, ')
          ..write('taxMinorUnits: $taxMinorUnits, ')
          ..write('taxType: $taxType, ')
          ..write('taxRate: $taxRate, ')
          ..write('totalMinorUnits: $totalMinorUnits, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseReceiptsTable extends PurchaseReceipts
    with TableInfo<$PurchaseReceiptsTable, PurchaseReceipt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseReceiptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseIdMeta = const VerificationMeta(
    'purchaseId',
  );
  @override
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
    'purchase_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES purchases (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    purchaseId,
    receivedAt,
    reference,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_receipts';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseReceipt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('purchase_id')) {
      context.handle(
        _purchaseIdMeta,
        purchaseId.isAcceptableOrUnknown(data['purchase_id']!, _purchaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_purchaseIdMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseReceipt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseReceipt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      purchaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_id'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PurchaseReceiptsTable createAlias(String alias) {
    return $PurchaseReceiptsTable(attachedDatabase, alias);
  }
}

class PurchaseReceipt extends DataClass implements Insertable<PurchaseReceipt> {
  final String id;
  final String purchaseId;
  final DateTime receivedAt;
  final String? reference;
  final String? notes;
  final DateTime createdAt;
  const PurchaseReceipt({
    required this.id,
    required this.purchaseId,
    required this.receivedAt,
    this.reference,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['purchase_id'] = Variable<String>(purchaseId);
    map['received_at'] = Variable<DateTime>(receivedAt);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PurchaseReceiptsCompanion toCompanion(bool nullToAbsent) {
    return PurchaseReceiptsCompanion(
      id: Value(id),
      purchaseId: Value(purchaseId),
      receivedAt: Value(receivedAt),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory PurchaseReceipt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseReceipt(
      id: serializer.fromJson<String>(json['id']),
      purchaseId: serializer.fromJson<String>(json['purchaseId']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      reference: serializer.fromJson<String?>(json['reference']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'purchaseId': serializer.toJson<String>(purchaseId),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'reference': serializer.toJson<String?>(reference),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PurchaseReceipt copyWith({
    String? id,
    String? purchaseId,
    DateTime? receivedAt,
    Value<String?> reference = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => PurchaseReceipt(
    id: id ?? this.id,
    purchaseId: purchaseId ?? this.purchaseId,
    receivedAt: receivedAt ?? this.receivedAt,
    reference: reference.present ? reference.value : this.reference,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  PurchaseReceipt copyWithCompanion(PurchaseReceiptsCompanion data) {
    return PurchaseReceipt(
      id: data.id.present ? data.id.value : this.id,
      purchaseId: data.purchaseId.present
          ? data.purchaseId.value
          : this.purchaseId,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      reference: data.reference.present ? data.reference.value : this.reference,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseReceipt(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('reference: $reference, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, purchaseId, receivedAt, reference, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseReceipt &&
          other.id == this.id &&
          other.purchaseId == this.purchaseId &&
          other.receivedAt == this.receivedAt &&
          other.reference == this.reference &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class PurchaseReceiptsCompanion extends UpdateCompanion<PurchaseReceipt> {
  final Value<String> id;
  final Value<String> purchaseId;
  final Value<DateTime> receivedAt;
  final Value<String?> reference;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PurchaseReceiptsCompanion({
    this.id = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.reference = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseReceiptsCompanion.insert({
    required String id,
    required String purchaseId,
    required DateTime receivedAt,
    this.reference = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       purchaseId = Value(purchaseId),
       receivedAt = Value(receivedAt);
  static Insertable<PurchaseReceipt> custom({
    Expression<String>? id,
    Expression<String>? purchaseId,
    Expression<DateTime>? receivedAt,
    Expression<String>? reference,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (receivedAt != null) 'received_at': receivedAt,
      if (reference != null) 'reference': reference,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseReceiptsCompanion copyWith({
    Value<String>? id,
    Value<String>? purchaseId,
    Value<DateTime>? receivedAt,
    Value<String?>? reference,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PurchaseReceiptsCompanion(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      receivedAt: receivedAt ?? this.receivedAt,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseReceiptsCompanion(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('reference: $reference, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseReceiptDetailsTable extends PurchaseReceiptDetails
    with TableInfo<$PurchaseReceiptDetailsTable, PurchaseReceiptDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseReceiptDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receiptIdMeta = const VerificationMeta(
    'receiptId',
  );
  @override
  late final GeneratedColumn<String> receiptId = GeneratedColumn<String>(
    'receipt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES purchase_receipts (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _purchaseDetailIdMeta = const VerificationMeta(
    'purchaseDetailId',
  );
  @override
  late final GeneratedColumn<String> purchaseDetailId = GeneratedColumn<String>(
    'purchase_detail_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES purchase_details (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _quantityMilliUnitsMeta =
      const VerificationMeta('quantityMilliUnits');
  @override
  late final GeneratedColumn<int> quantityMilliUnits = GeneratedColumn<int>(
    'quantity_milli_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inventoryMovementIdMeta =
      const VerificationMeta('inventoryMovementId');
  @override
  late final GeneratedColumn<String> inventoryMovementId =
      GeneratedColumn<String>(
        'inventory_movement_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES inventory_movements (id) ON DELETE RESTRICT',
        ),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    receiptId,
    purchaseDetailId,
    quantityMilliUnits,
    inventoryMovementId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_receipt_details';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseReceiptDetail> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('receipt_id')) {
      context.handle(
        _receiptIdMeta,
        receiptId.isAcceptableOrUnknown(data['receipt_id']!, _receiptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_receiptIdMeta);
    }
    if (data.containsKey('purchase_detail_id')) {
      context.handle(
        _purchaseDetailIdMeta,
        purchaseDetailId.isAcceptableOrUnknown(
          data['purchase_detail_id']!,
          _purchaseDetailIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchaseDetailIdMeta);
    }
    if (data.containsKey('quantity_milli_units')) {
      context.handle(
        _quantityMilliUnitsMeta,
        quantityMilliUnits.isAcceptableOrUnknown(
          data['quantity_milli_units']!,
          _quantityMilliUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityMilliUnitsMeta);
    }
    if (data.containsKey('inventory_movement_id')) {
      context.handle(
        _inventoryMovementIdMeta,
        inventoryMovementId.isAcceptableOrUnknown(
          data['inventory_movement_id']!,
          _inventoryMovementIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseReceiptDetail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseReceiptDetail(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      receiptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_id'],
      )!,
      purchaseDetailId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_detail_id'],
      )!,
      quantityMilliUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_milli_units'],
      )!,
      inventoryMovementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inventory_movement_id'],
      ),
    );
  }

  @override
  $PurchaseReceiptDetailsTable createAlias(String alias) {
    return $PurchaseReceiptDetailsTable(attachedDatabase, alias);
  }
}

class PurchaseReceiptDetail extends DataClass
    implements Insertable<PurchaseReceiptDetail> {
  final String id;
  final String receiptId;
  final String purchaseDetailId;
  final int quantityMilliUnits;

  /// Nulo cuando el producto no controla inventario.
  final String? inventoryMovementId;
  const PurchaseReceiptDetail({
    required this.id,
    required this.receiptId,
    required this.purchaseDetailId,
    required this.quantityMilliUnits,
    this.inventoryMovementId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['receipt_id'] = Variable<String>(receiptId);
    map['purchase_detail_id'] = Variable<String>(purchaseDetailId);
    map['quantity_milli_units'] = Variable<int>(quantityMilliUnits);
    if (!nullToAbsent || inventoryMovementId != null) {
      map['inventory_movement_id'] = Variable<String>(inventoryMovementId);
    }
    return map;
  }

  PurchaseReceiptDetailsCompanion toCompanion(bool nullToAbsent) {
    return PurchaseReceiptDetailsCompanion(
      id: Value(id),
      receiptId: Value(receiptId),
      purchaseDetailId: Value(purchaseDetailId),
      quantityMilliUnits: Value(quantityMilliUnits),
      inventoryMovementId: inventoryMovementId == null && nullToAbsent
          ? const Value.absent()
          : Value(inventoryMovementId),
    );
  }

  factory PurchaseReceiptDetail.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseReceiptDetail(
      id: serializer.fromJson<String>(json['id']),
      receiptId: serializer.fromJson<String>(json['receiptId']),
      purchaseDetailId: serializer.fromJson<String>(json['purchaseDetailId']),
      quantityMilliUnits: serializer.fromJson<int>(json['quantityMilliUnits']),
      inventoryMovementId: serializer.fromJson<String?>(
        json['inventoryMovementId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'receiptId': serializer.toJson<String>(receiptId),
      'purchaseDetailId': serializer.toJson<String>(purchaseDetailId),
      'quantityMilliUnits': serializer.toJson<int>(quantityMilliUnits),
      'inventoryMovementId': serializer.toJson<String?>(inventoryMovementId),
    };
  }

  PurchaseReceiptDetail copyWith({
    String? id,
    String? receiptId,
    String? purchaseDetailId,
    int? quantityMilliUnits,
    Value<String?> inventoryMovementId = const Value.absent(),
  }) => PurchaseReceiptDetail(
    id: id ?? this.id,
    receiptId: receiptId ?? this.receiptId,
    purchaseDetailId: purchaseDetailId ?? this.purchaseDetailId,
    quantityMilliUnits: quantityMilliUnits ?? this.quantityMilliUnits,
    inventoryMovementId: inventoryMovementId.present
        ? inventoryMovementId.value
        : this.inventoryMovementId,
  );
  PurchaseReceiptDetail copyWithCompanion(
    PurchaseReceiptDetailsCompanion data,
  ) {
    return PurchaseReceiptDetail(
      id: data.id.present ? data.id.value : this.id,
      receiptId: data.receiptId.present ? data.receiptId.value : this.receiptId,
      purchaseDetailId: data.purchaseDetailId.present
          ? data.purchaseDetailId.value
          : this.purchaseDetailId,
      quantityMilliUnits: data.quantityMilliUnits.present
          ? data.quantityMilliUnits.value
          : this.quantityMilliUnits,
      inventoryMovementId: data.inventoryMovementId.present
          ? data.inventoryMovementId.value
          : this.inventoryMovementId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseReceiptDetail(')
          ..write('id: $id, ')
          ..write('receiptId: $receiptId, ')
          ..write('purchaseDetailId: $purchaseDetailId, ')
          ..write('quantityMilliUnits: $quantityMilliUnits, ')
          ..write('inventoryMovementId: $inventoryMovementId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    receiptId,
    purchaseDetailId,
    quantityMilliUnits,
    inventoryMovementId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseReceiptDetail &&
          other.id == this.id &&
          other.receiptId == this.receiptId &&
          other.purchaseDetailId == this.purchaseDetailId &&
          other.quantityMilliUnits == this.quantityMilliUnits &&
          other.inventoryMovementId == this.inventoryMovementId);
}

class PurchaseReceiptDetailsCompanion
    extends UpdateCompanion<PurchaseReceiptDetail> {
  final Value<String> id;
  final Value<String> receiptId;
  final Value<String> purchaseDetailId;
  final Value<int> quantityMilliUnits;
  final Value<String?> inventoryMovementId;
  final Value<int> rowid;
  const PurchaseReceiptDetailsCompanion({
    this.id = const Value.absent(),
    this.receiptId = const Value.absent(),
    this.purchaseDetailId = const Value.absent(),
    this.quantityMilliUnits = const Value.absent(),
    this.inventoryMovementId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseReceiptDetailsCompanion.insert({
    required String id,
    required String receiptId,
    required String purchaseDetailId,
    required int quantityMilliUnits,
    this.inventoryMovementId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       receiptId = Value(receiptId),
       purchaseDetailId = Value(purchaseDetailId),
       quantityMilliUnits = Value(quantityMilliUnits);
  static Insertable<PurchaseReceiptDetail> custom({
    Expression<String>? id,
    Expression<String>? receiptId,
    Expression<String>? purchaseDetailId,
    Expression<int>? quantityMilliUnits,
    Expression<String>? inventoryMovementId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (receiptId != null) 'receipt_id': receiptId,
      if (purchaseDetailId != null) 'purchase_detail_id': purchaseDetailId,
      if (quantityMilliUnits != null)
        'quantity_milli_units': quantityMilliUnits,
      if (inventoryMovementId != null)
        'inventory_movement_id': inventoryMovementId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseReceiptDetailsCompanion copyWith({
    Value<String>? id,
    Value<String>? receiptId,
    Value<String>? purchaseDetailId,
    Value<int>? quantityMilliUnits,
    Value<String?>? inventoryMovementId,
    Value<int>? rowid,
  }) {
    return PurchaseReceiptDetailsCompanion(
      id: id ?? this.id,
      receiptId: receiptId ?? this.receiptId,
      purchaseDetailId: purchaseDetailId ?? this.purchaseDetailId,
      quantityMilliUnits: quantityMilliUnits ?? this.quantityMilliUnits,
      inventoryMovementId: inventoryMovementId ?? this.inventoryMovementId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (receiptId.present) {
      map['receipt_id'] = Variable<String>(receiptId.value);
    }
    if (purchaseDetailId.present) {
      map['purchase_detail_id'] = Variable<String>(purchaseDetailId.value);
    }
    if (quantityMilliUnits.present) {
      map['quantity_milli_units'] = Variable<int>(quantityMilliUnits.value);
    }
    if (inventoryMovementId.present) {
      map['inventory_movement_id'] = Variable<String>(
        inventoryMovementId.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseReceiptDetailsCompanion(')
          ..write('id: $id, ')
          ..write('receiptId: $receiptId, ')
          ..write('purchaseDetailId: $purchaseDetailId, ')
          ..write('quantityMilliUnits: $quantityMilliUnits, ')
          ..write('inventoryMovementId: $inventoryMovementId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupplierPaymentsTable extends SupplierPayments
    with TableInfo<$SupplierPaymentsTable, SupplierPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseIdMeta = const VerificationMeta(
    'purchaseId',
  );
  @override
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
    'purchase_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES purchases (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _amountMinorUnitsMeta = const VerificationMeta(
    'amountMinorUnits',
  );
  @override
  late final GeneratedColumn<int> amountMinorUnits = GeneratedColumn<int>(
    'amount_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES currencies (code)',
    ),
  );
  static const VerificationMeta _exchangeRateToBaseSnapshotMeta =
      const VerificationMeta('exchangeRateToBaseSnapshot');
  @override
  late final GeneratedColumn<String> exchangeRateToBaseSnapshot =
      GeneratedColumn<String>(
        'exchange_rate_to_base_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _appliedAmountMinorUnitsMeta =
      const VerificationMeta('appliedAmountMinorUnits');
  @override
  late final GeneratedColumn<int> appliedAmountMinorUnits =
      GeneratedColumn<int>(
        'applied_amount_minor_units',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
    'payment_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    purchaseId,
    amountMinorUnits,
    currencyCode,
    exchangeRateToBaseSnapshot,
    appliedAmountMinorUnits,
    paymentDate,
    paymentMethod,
    reference,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplier_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierPayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('purchase_id')) {
      context.handle(
        _purchaseIdMeta,
        purchaseId.isAcceptableOrUnknown(data['purchase_id']!, _purchaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_purchaseIdMeta);
    }
    if (data.containsKey('amount_minor_units')) {
      context.handle(
        _amountMinorUnitsMeta,
        amountMinorUnits.isAcceptableOrUnknown(
          data['amount_minor_units']!,
          _amountMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorUnitsMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('exchange_rate_to_base_snapshot')) {
      context.handle(
        _exchangeRateToBaseSnapshotMeta,
        exchangeRateToBaseSnapshot.isAcceptableOrUnknown(
          data['exchange_rate_to_base_snapshot']!,
          _exchangeRateToBaseSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exchangeRateToBaseSnapshotMeta);
    }
    if (data.containsKey('applied_amount_minor_units')) {
      context.handle(
        _appliedAmountMinorUnitsMeta,
        appliedAmountMinorUnits.isAcceptableOrUnknown(
          data['applied_amount_minor_units']!,
          _appliedAmountMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_appliedAmountMinorUnitsMeta);
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentDateMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierPayment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      purchaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_id'],
      )!,
      amountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor_units'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      exchangeRateToBaseSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exchange_rate_to_base_snapshot'],
      )!,
      appliedAmountMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}applied_amount_minor_units'],
      )!,
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_date'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SupplierPaymentsTable createAlias(String alias) {
    return $SupplierPaymentsTable(attachedDatabase, alias);
  }
}

class SupplierPayment extends DataClass implements Insertable<SupplierPayment> {
  final String id;
  final String purchaseId;

  /// Importe realmente entregado al proveedor.
  final int amountMinorUnits;
  final String currencyCode;

  /// Tasa histórica de la moneda del pago respecto a la moneda base.
  final String exchangeRateToBaseSnapshot;

  /// Equivalente aplicado a la deuda, en moneda de la compra.
  final int appliedAmountMinorUnits;
  final DateTime paymentDate;
  final String paymentMethod;
  final String? reference;
  final String? notes;
  final DateTime createdAt;
  const SupplierPayment({
    required this.id,
    required this.purchaseId,
    required this.amountMinorUnits,
    required this.currencyCode,
    required this.exchangeRateToBaseSnapshot,
    required this.appliedAmountMinorUnits,
    required this.paymentDate,
    required this.paymentMethod,
    this.reference,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['purchase_id'] = Variable<String>(purchaseId);
    map['amount_minor_units'] = Variable<int>(amountMinorUnits);
    map['currency_code'] = Variable<String>(currencyCode);
    map['exchange_rate_to_base_snapshot'] = Variable<String>(
      exchangeRateToBaseSnapshot,
    );
    map['applied_amount_minor_units'] = Variable<int>(appliedAmountMinorUnits);
    map['payment_date'] = Variable<DateTime>(paymentDate);
    map['payment_method'] = Variable<String>(paymentMethod);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SupplierPaymentsCompanion toCompanion(bool nullToAbsent) {
    return SupplierPaymentsCompanion(
      id: Value(id),
      purchaseId: Value(purchaseId),
      amountMinorUnits: Value(amountMinorUnits),
      currencyCode: Value(currencyCode),
      exchangeRateToBaseSnapshot: Value(exchangeRateToBaseSnapshot),
      appliedAmountMinorUnits: Value(appliedAmountMinorUnits),
      paymentDate: Value(paymentDate),
      paymentMethod: Value(paymentMethod),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory SupplierPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierPayment(
      id: serializer.fromJson<String>(json['id']),
      purchaseId: serializer.fromJson<String>(json['purchaseId']),
      amountMinorUnits: serializer.fromJson<int>(json['amountMinorUnits']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      exchangeRateToBaseSnapshot: serializer.fromJson<String>(
        json['exchangeRateToBaseSnapshot'],
      ),
      appliedAmountMinorUnits: serializer.fromJson<int>(
        json['appliedAmountMinorUnits'],
      ),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      reference: serializer.fromJson<String?>(json['reference']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'purchaseId': serializer.toJson<String>(purchaseId),
      'amountMinorUnits': serializer.toJson<int>(amountMinorUnits),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'exchangeRateToBaseSnapshot': serializer.toJson<String>(
        exchangeRateToBaseSnapshot,
      ),
      'appliedAmountMinorUnits': serializer.toJson<int>(
        appliedAmountMinorUnits,
      ),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'reference': serializer.toJson<String?>(reference),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SupplierPayment copyWith({
    String? id,
    String? purchaseId,
    int? amountMinorUnits,
    String? currencyCode,
    String? exchangeRateToBaseSnapshot,
    int? appliedAmountMinorUnits,
    DateTime? paymentDate,
    String? paymentMethod,
    Value<String?> reference = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => SupplierPayment(
    id: id ?? this.id,
    purchaseId: purchaseId ?? this.purchaseId,
    amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
    currencyCode: currencyCode ?? this.currencyCode,
    exchangeRateToBaseSnapshot:
        exchangeRateToBaseSnapshot ?? this.exchangeRateToBaseSnapshot,
    appliedAmountMinorUnits:
        appliedAmountMinorUnits ?? this.appliedAmountMinorUnits,
    paymentDate: paymentDate ?? this.paymentDate,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    reference: reference.present ? reference.value : this.reference,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  SupplierPayment copyWithCompanion(SupplierPaymentsCompanion data) {
    return SupplierPayment(
      id: data.id.present ? data.id.value : this.id,
      purchaseId: data.purchaseId.present
          ? data.purchaseId.value
          : this.purchaseId,
      amountMinorUnits: data.amountMinorUnits.present
          ? data.amountMinorUnits.value
          : this.amountMinorUnits,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      exchangeRateToBaseSnapshot: data.exchangeRateToBaseSnapshot.present
          ? data.exchangeRateToBaseSnapshot.value
          : this.exchangeRateToBaseSnapshot,
      appliedAmountMinorUnits: data.appliedAmountMinorUnits.present
          ? data.appliedAmountMinorUnits.value
          : this.appliedAmountMinorUnits,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      reference: data.reference.present ? data.reference.value : this.reference,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierPayment(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('exchangeRateToBaseSnapshot: $exchangeRateToBaseSnapshot, ')
          ..write('appliedAmountMinorUnits: $appliedAmountMinorUnits, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('reference: $reference, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    purchaseId,
    amountMinorUnits,
    currencyCode,
    exchangeRateToBaseSnapshot,
    appliedAmountMinorUnits,
    paymentDate,
    paymentMethod,
    reference,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierPayment &&
          other.id == this.id &&
          other.purchaseId == this.purchaseId &&
          other.amountMinorUnits == this.amountMinorUnits &&
          other.currencyCode == this.currencyCode &&
          other.exchangeRateToBaseSnapshot == this.exchangeRateToBaseSnapshot &&
          other.appliedAmountMinorUnits == this.appliedAmountMinorUnits &&
          other.paymentDate == this.paymentDate &&
          other.paymentMethod == this.paymentMethod &&
          other.reference == this.reference &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class SupplierPaymentsCompanion extends UpdateCompanion<SupplierPayment> {
  final Value<String> id;
  final Value<String> purchaseId;
  final Value<int> amountMinorUnits;
  final Value<String> currencyCode;
  final Value<String> exchangeRateToBaseSnapshot;
  final Value<int> appliedAmountMinorUnits;
  final Value<DateTime> paymentDate;
  final Value<String> paymentMethod;
  final Value<String?> reference;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SupplierPaymentsCompanion({
    this.id = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.amountMinorUnits = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.exchangeRateToBaseSnapshot = const Value.absent(),
    this.appliedAmountMinorUnits = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.reference = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupplierPaymentsCompanion.insert({
    required String id,
    required String purchaseId,
    required int amountMinorUnits,
    required String currencyCode,
    required String exchangeRateToBaseSnapshot,
    required int appliedAmountMinorUnits,
    required DateTime paymentDate,
    required String paymentMethod,
    this.reference = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       purchaseId = Value(purchaseId),
       amountMinorUnits = Value(amountMinorUnits),
       currencyCode = Value(currencyCode),
       exchangeRateToBaseSnapshot = Value(exchangeRateToBaseSnapshot),
       appliedAmountMinorUnits = Value(appliedAmountMinorUnits),
       paymentDate = Value(paymentDate),
       paymentMethod = Value(paymentMethod);
  static Insertable<SupplierPayment> custom({
    Expression<String>? id,
    Expression<String>? purchaseId,
    Expression<int>? amountMinorUnits,
    Expression<String>? currencyCode,
    Expression<String>? exchangeRateToBaseSnapshot,
    Expression<int>? appliedAmountMinorUnits,
    Expression<DateTime>? paymentDate,
    Expression<String>? paymentMethod,
    Expression<String>? reference,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (amountMinorUnits != null) 'amount_minor_units': amountMinorUnits,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (exchangeRateToBaseSnapshot != null)
        'exchange_rate_to_base_snapshot': exchangeRateToBaseSnapshot,
      if (appliedAmountMinorUnits != null)
        'applied_amount_minor_units': appliedAmountMinorUnits,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (reference != null) 'reference': reference,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupplierPaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? purchaseId,
    Value<int>? amountMinorUnits,
    Value<String>? currencyCode,
    Value<String>? exchangeRateToBaseSnapshot,
    Value<int>? appliedAmountMinorUnits,
    Value<DateTime>? paymentDate,
    Value<String>? paymentMethod,
    Value<String?>? reference,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SupplierPaymentsCompanion(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      amountMinorUnits: amountMinorUnits ?? this.amountMinorUnits,
      currencyCode: currencyCode ?? this.currencyCode,
      exchangeRateToBaseSnapshot:
          exchangeRateToBaseSnapshot ?? this.exchangeRateToBaseSnapshot,
      appliedAmountMinorUnits:
          appliedAmountMinorUnits ?? this.appliedAmountMinorUnits,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
    }
    if (amountMinorUnits.present) {
      map['amount_minor_units'] = Variable<int>(amountMinorUnits.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (exchangeRateToBaseSnapshot.present) {
      map['exchange_rate_to_base_snapshot'] = Variable<String>(
        exchangeRateToBaseSnapshot.value,
      );
    }
    if (appliedAmountMinorUnits.present) {
      map['applied_amount_minor_units'] = Variable<int>(
        appliedAmountMinorUnits.value,
      );
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplierPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('amountMinorUnits: $amountMinorUnits, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('exchangeRateToBaseSnapshot: $exchangeRateToBaseSnapshot, ')
          ..write('appliedAmountMinorUnits: $appliedAmountMinorUnits, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('reference: $reference, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CurrenciesTable currencies = $CurrenciesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $ProductPricesTable productPrices = $ProductPricesTable(this);
  late final $InventoryMovementsTable inventoryMovements =
      $InventoryMovementsTable(this);
  late final $InventoryBalancesTable inventoryBalances =
      $InventoryBalancesTable(this);
  late final $SuppliersTable suppliers = $SuppliersTable(this);
  late final $ExchangeRatesTable exchangeRates = $ExchangeRatesTable(this);
  late final $PurchasesTable purchases = $PurchasesTable(this);
  late final $PurchaseDetailsTable purchaseDetails = $PurchaseDetailsTable(
    this,
  );
  late final $PurchaseReceiptsTable purchaseReceipts = $PurchaseReceiptsTable(
    this,
  );
  late final $PurchaseReceiptDetailsTable purchaseReceiptDetails =
      $PurchaseReceiptDetailsTable(this);
  late final $SupplierPaymentsTable supplierPayments = $SupplierPaymentsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    currencies,
    products,
    productPrices,
    inventoryMovements,
    inventoryBalances,
    suppliers,
    exchangeRates,
    purchases,
    purchaseDetails,
    purchaseReceipts,
    purchaseReceiptDetails,
    supplierPayments,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'products',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('product_prices', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CurrenciesTableCreateCompanionBuilder = CurrenciesCompanion Function({
  required String code,
  required String name,
  required String symbol,
  Value<int> decimalDigits,
  Value<bool> isActive,
  Value<bool> isBase,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$CurrenciesTableUpdateCompanionBuilder = CurrenciesCompanion Function({
  Value<String> code,
  Value<String> name,
  Value<String> symbol,
  Value<int> decimalDigits,
  Value<bool> isActive,
  Value<bool> isBase,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$CurrenciesTableReferences
    extends BaseReferences<_$AppDatabase, $CurrenciesTable, Currency> {
  $$CurrenciesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductPricesTable, List<ProductPrice>>
  _productPricesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.productPrices,
    aliasName: 'currencies__code__product_prices__currency_code',
  );

  $$ProductPricesTableProcessedTableManager get productPricesRefs {
    final manager = $$ProductPricesTableTableManager($_db, $_db.productPrices)
        .filter(
          (f) => f.currencyCode.code.sqlEquals($_itemColumn<String>('code')!),
        );

    final cache = $_typedResult.readTableOrNull(_productPricesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExchangeRatesTable, List<ExchangeRate>>
  _exchangeRatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exchangeRates,
    aliasName: 'currencies__code__exchange_rates__currency_code',
  );

  $$ExchangeRatesTableProcessedTableManager get exchangeRatesRefs {
    final manager = $$ExchangeRatesTableTableManager($_db, $_db.exchangeRates)
        .filter(
          (f) => f.currencyCode.code.sqlEquals($_itemColumn<String>('code')!),
        );

    final cache = $_typedResult.readTableOrNull(_exchangeRatesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PurchasesTable, List<Purchase>>
  _purchasesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.purchases,
    aliasName: 'currencies__code__purchases__currency_code',
  );

  $$PurchasesTableProcessedTableManager get purchasesRefs {
    final manager = $$PurchasesTableTableManager($_db, $_db.purchases).filter(
      (f) => f.currencyCode.code.sqlEquals($_itemColumn<String>('code')!),
    );

    final cache = $_typedResult.readTableOrNull(_purchasesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SupplierPaymentsTable, List<SupplierPayment>>
  _supplierPaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.supplierPayments,
    aliasName: 'currencies__code__supplier_payments__currency_code',
  );

  $$SupplierPaymentsTableProcessedTableManager get supplierPaymentsRefs {
    final manager =
        $$SupplierPaymentsTableTableManager($_db, $_db.supplierPayments).filter(
          (f) => f.currencyCode.code.sqlEquals($_itemColumn<String>('code')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _supplierPaymentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CurrenciesTableFilterComposer
    extends Composer<_$AppDatabase, $CurrenciesTable> {
  $$CurrenciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get decimalDigits => $composableBuilder(
    column: $table.decimalDigits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBase => $composableBuilder(
    column: $table.isBase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> productPricesRefs(
    Expression<bool> Function($$ProductPricesTableFilterComposer f) f,
  ) {
    final $$ProductPricesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.productPrices,
      getReferencedColumn: (t) => t.currencyCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductPricesTableFilterComposer(
            $db: $db,
            $table: $db.productPrices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exchangeRatesRefs(
    Expression<bool> Function($$ExchangeRatesTableFilterComposer f) f,
  ) {
    final $$ExchangeRatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.exchangeRates,
      getReferencedColumn: (t) => t.currencyCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExchangeRatesTableFilterComposer(
            $db: $db,
            $table: $db.exchangeRates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> purchasesRefs(
    Expression<bool> Function($$PurchasesTableFilterComposer f) f,
  ) {
    final $$PurchasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.currencyCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableFilterComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> supplierPaymentsRefs(
    Expression<bool> Function($$SupplierPaymentsTableFilterComposer f) f,
  ) {
    final $$SupplierPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.supplierPayments,
      getReferencedColumn: (t) => t.currencyCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.supplierPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CurrenciesTableOrderingComposer
    extends Composer<_$AppDatabase, $CurrenciesTable> {
  $$CurrenciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get decimalDigits => $composableBuilder(
    column: $table.decimalDigits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBase => $composableBuilder(
    column: $table.isBase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CurrenciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CurrenciesTable> {
  $$CurrenciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<int> get decimalDigits => $composableBuilder(
    column: $table.decimalDigits,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isBase =>
      $composableBuilder(column: $table.isBase, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> productPricesRefs<T extends Object>(
    Expression<T> Function($$ProductPricesTableAnnotationComposer a) f,
  ) {
    final $$ProductPricesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.productPrices,
      getReferencedColumn: (t) => t.currencyCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductPricesTableAnnotationComposer(
            $db: $db,
            $table: $db.productPrices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exchangeRatesRefs<T extends Object>(
    Expression<T> Function($$ExchangeRatesTableAnnotationComposer a) f,
  ) {
    final $$ExchangeRatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.exchangeRates,
      getReferencedColumn: (t) => t.currencyCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExchangeRatesTableAnnotationComposer(
            $db: $db,
            $table: $db.exchangeRates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> purchasesRefs<T extends Object>(
    Expression<T> Function($$PurchasesTableAnnotationComposer a) f,
  ) {
    final $$PurchasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.currencyCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableAnnotationComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> supplierPaymentsRefs<T extends Object>(
    Expression<T> Function($$SupplierPaymentsTableAnnotationComposer a) f,
  ) {
    final $$SupplierPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.supplierPayments,
      getReferencedColumn: (t) => t.currencyCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CurrenciesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CurrenciesTable,
          Currency,
          $$CurrenciesTableFilterComposer,
          $$CurrenciesTableOrderingComposer,
          $$CurrenciesTableAnnotationComposer,
          $$CurrenciesTableCreateCompanionBuilder,
          $$CurrenciesTableUpdateCompanionBuilder,
          (Currency, $$CurrenciesTableReferences),
          Currency,
          PrefetchHooks Function({
            bool productPricesRefs,
            bool exchangeRatesRefs,
            bool purchasesRefs,
            bool supplierPaymentsRefs,
          })
        > {
  $$CurrenciesTableTableManager(_$AppDatabase db, $CurrenciesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CurrenciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CurrenciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CurrenciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<int> decimalDigits = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isBase = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CurrenciesCompanion(
                code: code,
                name: name,
                symbol: symbol,
                decimalDigits: decimalDigits,
                isActive: isActive,
                isBase: isBase,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String name,
                required String symbol,
                Value<int> decimalDigits = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isBase = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CurrenciesCompanion.insert(
                code: code,
                name: name,
                symbol: symbol,
                decimalDigits: decimalDigits,
                isActive: isActive,
                isBase: isBase,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CurrenciesTable, Currency>(table),
                  $$CurrenciesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                productPricesRefs = false,
                exchangeRatesRefs = false,
                purchasesRefs = false,
                supplierPaymentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (productPricesRefs) db.productPrices,
                    if (exchangeRatesRefs) db.exchangeRates,
                    if (purchasesRefs) db.purchases,
                    if (supplierPaymentsRefs) db.supplierPayments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (productPricesRefs)
                        await $_getPrefetchedDataByColumns<
                          Currency,
                          $CurrenciesTable,
                          ProductPrice,
                          $ProductPricesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CurrenciesTableReferences
                              ._productPricesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CurrenciesTableReferences(
                                db,
                                table,
                                p0,
                              ).productPricesRefs,
                          currentColumn: 'code',
                          referencedColumn: 'currency_code',
                          typedResults: items,
                        ),
                      if (exchangeRatesRefs)
                        await $_getPrefetchedDataByColumns<
                          Currency,
                          $CurrenciesTable,
                          ExchangeRate,
                          $ExchangeRatesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CurrenciesTableReferences
                              ._exchangeRatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CurrenciesTableReferences(
                                db,
                                table,
                                p0,
                              ).exchangeRatesRefs,
                          currentColumn: 'code',
                          referencedColumn: 'currency_code',
                          typedResults: items,
                        ),
                      if (purchasesRefs)
                        await $_getPrefetchedDataByColumns<
                          Currency,
                          $CurrenciesTable,
                          Purchase,
                          $PurchasesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CurrenciesTableReferences
                              ._purchasesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CurrenciesTableReferences(
                                db,
                                table,
                                p0,
                              ).purchasesRefs,
                          currentColumn: 'code',
                          referencedColumn: 'currency_code',
                          typedResults: items,
                        ),
                      if (supplierPaymentsRefs)
                        await $_getPrefetchedDataByColumns<
                          Currency,
                          $CurrenciesTable,
                          SupplierPayment,
                          $SupplierPaymentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CurrenciesTableReferences
                              ._supplierPaymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CurrenciesTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierPaymentsRefs,
                          currentColumn: 'code',
                          referencedColumn: 'currency_code',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CurrenciesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CurrenciesTable,
      Currency,
      $$CurrenciesTableFilterComposer,
      $$CurrenciesTableOrderingComposer,
      $$CurrenciesTableAnnotationComposer,
      $$CurrenciesTableCreateCompanionBuilder,
      $$CurrenciesTableUpdateCompanionBuilder,
      (Currency, $$CurrenciesTableReferences),
      Currency,
      PrefetchHooks Function({
        bool productPricesRefs,
        bool exchangeRatesRefs,
        bool purchasesRefs,
        bool supplierPaymentsRefs,
      })
    >;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  required String id,
  required String sku,
  required String name,
  Value<String?> description,
  Value<String?> category,
  Value<String> unit,
  Value<bool> trackInventory,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<String> id,
  Value<String> sku,
  Value<String> name,
  Value<String?> description,
  Value<String?> category,
  Value<String> unit,
  Value<bool> trackInventory,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, Product> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductPricesTable, List<ProductPrice>>
  _productPricesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.productPrices,
    aliasName: 'products__id__product_prices__product_id',
  );

  $$ProductPricesTableProcessedTableManager get productPricesRefs {
    final manager = $$ProductPricesTableTableManager(
      $_db,
      $_db.productPrices,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_productPricesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InventoryMovementsTable, List<InventoryMovement>>
  _inventoryMovementsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.inventoryMovements,
        aliasName: 'products__id__inventory_movements__product_id',
      );

  $$InventoryMovementsTableProcessedTableManager get inventoryMovementsRefs {
    final manager = $$InventoryMovementsTableTableManager(
      $_db,
      $_db.inventoryMovements,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _inventoryMovementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InventoryBalancesTable, List<InventoryBalance>>
  _inventoryBalancesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.inventoryBalances,
        aliasName: 'products__id__inventory_balances__product_id',
      );

  $$InventoryBalancesTableProcessedTableManager get inventoryBalancesRefs {
    final manager = $$InventoryBalancesTableTableManager(
      $_db,
      $_db.inventoryBalances,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _inventoryBalancesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PurchaseDetailsTable, List<PurchaseDetail>>
  _purchaseDetailsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.purchaseDetails,
    aliasName: 'products__id__purchase_details__product_id',
  );

  $$PurchaseDetailsTableProcessedTableManager get purchaseDetailsRefs {
    final manager = $$PurchaseDetailsTableTableManager(
      $_db,
      $_db.purchaseDetails,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _purchaseDetailsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get trackInventory => $composableBuilder(
    column: $table.trackInventory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> productPricesRefs(
    Expression<bool> Function($$ProductPricesTableFilterComposer f) f,
  ) {
    final $$ProductPricesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productPrices,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductPricesTableFilterComposer(
            $db: $db,
            $table: $db.productPrices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> inventoryMovementsRefs(
    Expression<bool> Function($$InventoryMovementsTableFilterComposer f) f,
  ) {
    final $$InventoryMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inventoryMovements,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryMovementsTableFilterComposer(
            $db: $db,
            $table: $db.inventoryMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> inventoryBalancesRefs(
    Expression<bool> Function($$InventoryBalancesTableFilterComposer f) f,
  ) {
    final $$InventoryBalancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inventoryBalances,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryBalancesTableFilterComposer(
            $db: $db,
            $table: $db.inventoryBalances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> purchaseDetailsRefs(
    Expression<bool> Function($$PurchaseDetailsTableFilterComposer f) f,
  ) {
    final $$PurchaseDetailsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseDetails,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseDetailsTableFilterComposer(
            $db: $db,
            $table: $db.purchaseDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get trackInventory => $composableBuilder(
    column: $table.trackInventory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<bool> get trackInventory => $composableBuilder(
    column: $table.trackInventory,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> productPricesRefs<T extends Object>(
    Expression<T> Function($$ProductPricesTableAnnotationComposer a) f,
  ) {
    final $$ProductPricesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productPrices,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductPricesTableAnnotationComposer(
            $db: $db,
            $table: $db.productPrices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> inventoryMovementsRefs<T extends Object>(
    Expression<T> Function($$InventoryMovementsTableAnnotationComposer a) f,
  ) {
    final $$InventoryMovementsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.inventoryMovements,
          getReferencedColumn: (t) => t.productId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InventoryMovementsTableAnnotationComposer(
                $db: $db,
                $table: $db.inventoryMovements,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> inventoryBalancesRefs<T extends Object>(
    Expression<T> Function($$InventoryBalancesTableAnnotationComposer a) f,
  ) {
    final $$InventoryBalancesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.inventoryBalances,
          getReferencedColumn: (t) => t.productId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InventoryBalancesTableAnnotationComposer(
                $db: $db,
                $table: $db.inventoryBalances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> purchaseDetailsRefs<T extends Object>(
    Expression<T> Function($$PurchaseDetailsTableAnnotationComposer a) f,
  ) {
    final $$PurchaseDetailsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseDetails,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseDetailsTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          Product,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (Product, $$ProductsTableReferences),
          Product,
          PrefetchHooks Function({
            bool productPricesRefs,
            bool inventoryMovementsRefs,
            bool inventoryBalancesRefs,
            bool purchaseDetailsRefs,
          })
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sku = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<bool> trackInventory = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                sku: sku,
                name: name,
                description: description,
                category: category,
                unit: unit,
                trackInventory: trackInventory,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sku,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<bool> trackInventory = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                sku: sku,
                name: name,
                description: description,
                category: category,
                unit: unit,
                trackInventory: trackInventory,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductsTable, Product>(table),
                  $$ProductsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                productPricesRefs = false,
                inventoryMovementsRefs = false,
                inventoryBalancesRefs = false,
                purchaseDetailsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (productPricesRefs) db.productPrices,
                    if (inventoryMovementsRefs) db.inventoryMovements,
                    if (inventoryBalancesRefs) db.inventoryBalances,
                    if (purchaseDetailsRefs) db.purchaseDetails,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (productPricesRefs)
                        await $_getPrefetchedDataByColumns<
                          Product,
                          $ProductsTable,
                          ProductPrice,
                          $ProductPricesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._productPricesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).productPricesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'product_id',
                          typedResults: items,
                        ),
                      if (inventoryMovementsRefs)
                        await $_getPrefetchedDataByColumns<
                          Product,
                          $ProductsTable,
                          InventoryMovement,
                          $InventoryMovementsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._inventoryMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).inventoryMovementsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'product_id',
                          typedResults: items,
                        ),
                      if (inventoryBalancesRefs)
                        await $_getPrefetchedDataByColumns<
                          Product,
                          $ProductsTable,
                          InventoryBalance,
                          $InventoryBalancesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._inventoryBalancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).inventoryBalancesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'product_id',
                          typedResults: items,
                        ),
                      if (purchaseDetailsRefs)
                        await $_getPrefetchedDataByColumns<
                          Product,
                          $ProductsTable,
                          PurchaseDetail,
                          $PurchaseDetailsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._purchaseDetailsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).purchaseDetailsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'product_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      Product,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (Product, $$ProductsTableReferences),
      Product,
      PrefetchHooks Function({
        bool productPricesRefs,
        bool inventoryMovementsRefs,
        bool inventoryBalancesRefs,
        bool purchaseDetailsRefs,
      })
    >;
typedef $$ProductPricesTableCreateCompanionBuilder =
    ProductPricesCompanion Function({
      required String productId,
      required String currencyCode,
      required int amountMinorUnits,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ProductPricesTableUpdateCompanionBuilder =
    ProductPricesCompanion Function({
      Value<String> productId,
      Value<String> currencyCode,
      Value<int> amountMinorUnits,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ProductPricesTableReferences
    extends BaseReferences<_$AppDatabase, $ProductPricesTable, ProductPrice> {
  $$ProductPricesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('product_prices__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CurrenciesTable _currencyCodeTable(_$AppDatabase db) => db.currencies
      .createAlias('product_prices__currency_code__currencies__code');

  $$CurrenciesTableProcessedTableManager get currencyCode {
    final $_column = $_itemColumn<String>('currency_code')!;

    final manager = $$CurrenciesTableTableManager(
      $_db,
      $_db.currencies,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currencyCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProductPricesTableFilterComposer
    extends Composer<_$AppDatabase, $ProductPricesTable> {
  $$ProductPricesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CurrenciesTableFilterComposer get currencyCode {
    final $$CurrenciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableFilterComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductPricesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductPricesTable> {
  $$ProductPricesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CurrenciesTableOrderingComposer get currencyCode {
    final $$CurrenciesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableOrderingComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductPricesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductPricesTable> {
  $$ProductPricesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CurrenciesTableAnnotationComposer get currencyCode {
    final $$CurrenciesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableAnnotationComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductPricesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductPricesTable,
          ProductPrice,
          $$ProductPricesTableFilterComposer,
          $$ProductPricesTableOrderingComposer,
          $$ProductPricesTableAnnotationComposer,
          $$ProductPricesTableCreateCompanionBuilder,
          $$ProductPricesTableUpdateCompanionBuilder,
          (ProductPrice, $$ProductPricesTableReferences),
          ProductPrice,
          PrefetchHooks Function({bool productId, bool currencyCode})
        > {
  $$ProductPricesTableTableManager(_$AppDatabase db, $ProductPricesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductPricesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductPricesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductPricesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> productId = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> amountMinorUnits = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductPricesCompanion(
                productId: productId,
                currencyCode: currencyCode,
                amountMinorUnits: amountMinorUnits,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String productId,
                required String currencyCode,
                required int amountMinorUnits,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductPricesCompanion.insert(
                productId: productId,
                currencyCode: currencyCode,
                amountMinorUnits: amountMinorUnits,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductPricesTable, ProductPrice>(table),
                  $$ProductPricesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false, currencyCode = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (productId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.productId,
                        referencedTable: $$ProductPricesTableReferences
                            ._productIdTable(db),
                        referencedColumn: $$ProductPricesTableReferences
                            ._productIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (currencyCode) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.currencyCode,
                        referencedTable: $$ProductPricesTableReferences
                            ._currencyCodeTable(db),
                        referencedColumn: $$ProductPricesTableReferences
                            ._currencyCodeTable(db)
                            .code,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProductPricesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductPricesTable,
      ProductPrice,
      $$ProductPricesTableFilterComposer,
      $$ProductPricesTableOrderingComposer,
      $$ProductPricesTableAnnotationComposer,
      $$ProductPricesTableCreateCompanionBuilder,
      $$ProductPricesTableUpdateCompanionBuilder,
      (ProductPrice, $$ProductPricesTableReferences),
      ProductPrice,
      PrefetchHooks Function({bool productId, bool currencyCode})
    >;
typedef $$InventoryMovementsTableCreateCompanionBuilder =
    InventoryMovementsCompanion Function({
      required String id,
      required String productId,
      required String movementType,
      required int quantityMilliUnits,
      required String reason,
      Value<String?> reference,
      Value<String?> correctionOfId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$InventoryMovementsTableUpdateCompanionBuilder =
    InventoryMovementsCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> movementType,
      Value<int> quantityMilliUnits,
      Value<String> reason,
      Value<String?> reference,
      Value<String?> correctionOfId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$InventoryMovementsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InventoryMovementsTable,
          InventoryMovement
        > {
  $$InventoryMovementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('inventory_movements__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InventoryMovementsTable _correctionOfIdTable(_$AppDatabase db) =>
      db.inventoryMovements.createAlias(
        'inventory_movements__correction_of_id__inventory_movements__id',
      );

  $$InventoryMovementsTableProcessedTableManager? get correctionOfId {
    final $_column = $_itemColumn<String>('correction_of_id');
    if ($_column == null) return null;
    final manager = $$InventoryMovementsTableTableManager(
      $_db,
      $_db.inventoryMovements,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_correctionOfIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $PurchaseReceiptDetailsTable,
    List<PurchaseReceiptDetail>
  >
  _purchaseReceiptDetailsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.purchaseReceiptDetails,
        aliasName: 'inventory_movements__id__purchase_receipt_details__inventory_movement_id',
      );

  $$PurchaseReceiptDetailsTableProcessedTableManager
  get purchaseReceiptDetailsRefs {
    final manager =
        $$PurchaseReceiptDetailsTableTableManager(
          $_db,
          $_db.purchaseReceiptDetails,
        ).filter(
          (f) =>
              f.inventoryMovementId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _purchaseReceiptDetailsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InventoryMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryMovementsTable> {
  $$InventoryMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityMilliUnits => $composableBuilder(
    column: $table.quantityMilliUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryMovementsTableFilterComposer get correctionOfId {
    final $$InventoryMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.correctionOfId,
      referencedTable: $db.inventoryMovements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryMovementsTableFilterComposer(
            $db: $db,
            $table: $db.inventoryMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> purchaseReceiptDetailsRefs(
    Expression<bool> Function($$PurchaseReceiptDetailsTableFilterComposer f) f,
  ) {
    final $$PurchaseReceiptDetailsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.purchaseReceiptDetails,
          getReferencedColumn: (t) => t.inventoryMovementId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PurchaseReceiptDetailsTableFilterComposer(
                $db: $db,
                $table: $db.purchaseReceiptDetails,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$InventoryMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryMovementsTable> {
  $$InventoryMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityMilliUnits => $composableBuilder(
    column: $table.quantityMilliUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryMovementsTableOrderingComposer get correctionOfId {
    final $$InventoryMovementsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.correctionOfId,
      referencedTable: $db.inventoryMovements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryMovementsTableOrderingComposer(
            $db: $db,
            $table: $db.inventoryMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryMovementsTable> {
  $$InventoryMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityMilliUnits => $composableBuilder(
    column: $table.quantityMilliUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryMovementsTableAnnotationComposer get correctionOfId {
    final $$InventoryMovementsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.correctionOfId,
          referencedTable: $db.inventoryMovements,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InventoryMovementsTableAnnotationComposer(
                $db: $db,
                $table: $db.inventoryMovements,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> purchaseReceiptDetailsRefs<T extends Object>(
    Expression<T> Function($$PurchaseReceiptDetailsTableAnnotationComposer a) f,
  ) {
    final $$PurchaseReceiptDetailsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.purchaseReceiptDetails,
          getReferencedColumn: (t) => t.inventoryMovementId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PurchaseReceiptDetailsTableAnnotationComposer(
                $db: $db,
                $table: $db.purchaseReceiptDetails,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$InventoryMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InventoryMovementsTable,
          InventoryMovement,
          $$InventoryMovementsTableFilterComposer,
          $$InventoryMovementsTableOrderingComposer,
          $$InventoryMovementsTableAnnotationComposer,
          $$InventoryMovementsTableCreateCompanionBuilder,
          $$InventoryMovementsTableUpdateCompanionBuilder,
          (InventoryMovement, $$InventoryMovementsTableReferences),
          InventoryMovement,
          PrefetchHooks Function({
            bool productId,
            bool correctionOfId,
            bool purchaseReceiptDetailsRefs,
          })
        > {
  $$InventoryMovementsTableTableManager(
    _$AppDatabase db,
    $InventoryMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryMovementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> movementType = const Value.absent(),
                Value<int> quantityMilliUnits = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> correctionOfId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryMovementsCompanion(
                id: id,
                productId: productId,
                movementType: movementType,
                quantityMilliUnits: quantityMilliUnits,
                reason: reason,
                reference: reference,
                correctionOfId: correctionOfId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String movementType,
                required int quantityMilliUnits,
                required String reason,
                Value<String?> reference = const Value.absent(),
                Value<String?> correctionOfId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryMovementsCompanion.insert(
                id: id,
                productId: productId,
                movementType: movementType,
                quantityMilliUnits: quantityMilliUnits,
                reason: reason,
                reference: reference,
                correctionOfId: correctionOfId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InventoryMovementsTable, InventoryMovement>(
                    table,
                  ),
                  $$InventoryMovementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                productId = false,
                correctionOfId = false,
                purchaseReceiptDetailsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (purchaseReceiptDetailsRefs) db.purchaseReceiptDetails,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (productId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.productId,
                            referencedTable: $$InventoryMovementsTableReferences
                                ._productIdTable(db),
                            referencedColumn:
                                $$InventoryMovementsTableReferences
                                    ._productIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (correctionOfId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.correctionOfId,
                            referencedTable: $$InventoryMovementsTableReferences
                                ._correctionOfIdTable(db),
                            referencedColumn:
                                $$InventoryMovementsTableReferences
                                    ._correctionOfIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (purchaseReceiptDetailsRefs)
                        await $_getPrefetchedDataByColumns<
                          InventoryMovement,
                          $InventoryMovementsTable,
                          PurchaseReceiptDetail,
                          $PurchaseReceiptDetailsTable
                        >(
                          currentTable: table,
                          referencedTable: $$InventoryMovementsTableReferences
                              ._purchaseReceiptDetailsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InventoryMovementsTableReferences(
                                db,
                                table,
                                p0,
                              ).purchaseReceiptDetailsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'inventory_movement_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$InventoryMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InventoryMovementsTable,
      InventoryMovement,
      $$InventoryMovementsTableFilterComposer,
      $$InventoryMovementsTableOrderingComposer,
      $$InventoryMovementsTableAnnotationComposer,
      $$InventoryMovementsTableCreateCompanionBuilder,
      $$InventoryMovementsTableUpdateCompanionBuilder,
      (InventoryMovement, $$InventoryMovementsTableReferences),
      InventoryMovement,
      PrefetchHooks Function({
        bool productId,
        bool correctionOfId,
        bool purchaseReceiptDetailsRefs,
      })
    >;
typedef $$InventoryBalancesTableCreateCompanionBuilder =
    InventoryBalancesCompanion Function({
      required String productId,
      Value<int> quantityMilliUnits,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$InventoryBalancesTableUpdateCompanionBuilder =
    InventoryBalancesCompanion Function({
      Value<String> productId,
      Value<int> quantityMilliUnits,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$InventoryBalancesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InventoryBalancesTable,
          InventoryBalance
        > {
  $$InventoryBalancesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('inventory_balances__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InventoryBalancesTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryBalancesTable> {
  $$InventoryBalancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get quantityMilliUnits => $composableBuilder(
    column: $table.quantityMilliUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryBalancesTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryBalancesTable> {
  $$InventoryBalancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get quantityMilliUnits => $composableBuilder(
    column: $table.quantityMilliUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryBalancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryBalancesTable> {
  $$InventoryBalancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get quantityMilliUnits => $composableBuilder(
    column: $table.quantityMilliUnits,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryBalancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InventoryBalancesTable,
          InventoryBalance,
          $$InventoryBalancesTableFilterComposer,
          $$InventoryBalancesTableOrderingComposer,
          $$InventoryBalancesTableAnnotationComposer,
          $$InventoryBalancesTableCreateCompanionBuilder,
          $$InventoryBalancesTableUpdateCompanionBuilder,
          (InventoryBalance, $$InventoryBalancesTableReferences),
          InventoryBalance,
          PrefetchHooks Function({bool productId})
        > {
  $$InventoryBalancesTableTableManager(
    _$AppDatabase db,
    $InventoryBalancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryBalancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryBalancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryBalancesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> productId = const Value.absent(),
                Value<int> quantityMilliUnits = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryBalancesCompanion(
                productId: productId,
                quantityMilliUnits: quantityMilliUnits,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String productId,
                Value<int> quantityMilliUnits = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryBalancesCompanion.insert(
                productId: productId,
                quantityMilliUnits: quantityMilliUnits,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InventoryBalancesTable, InventoryBalance>(table),
                  $$InventoryBalancesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (productId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.productId,
                        referencedTable: $$InventoryBalancesTableReferences
                            ._productIdTable(db),
                        referencedColumn: $$InventoryBalancesTableReferences
                            ._productIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InventoryBalancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InventoryBalancesTable,
      InventoryBalance,
      $$InventoryBalancesTableFilterComposer,
      $$InventoryBalancesTableOrderingComposer,
      $$InventoryBalancesTableAnnotationComposer,
      $$InventoryBalancesTableCreateCompanionBuilder,
      $$InventoryBalancesTableUpdateCompanionBuilder,
      (InventoryBalance, $$InventoryBalancesTableReferences),
      InventoryBalance,
      PrefetchHooks Function({bool productId})
    >;
typedef $$SuppliersTableCreateCompanionBuilder = SuppliersCompanion Function({
  required String id,
  required String name,
  Value<String?> taxId,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> address,
  Value<String?> notes,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$SuppliersTableUpdateCompanionBuilder = SuppliersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> taxId,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> address,
  Value<String?> notes,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$SuppliersTableReferences
    extends BaseReferences<_$AppDatabase, $SuppliersTable, Supplier> {
  $$SuppliersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PurchasesTable, List<Purchase>>
  _purchasesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.purchases,
    aliasName: 'suppliers__id__purchases__supplier_id',
  );

  $$PurchasesTableProcessedTableManager get purchasesRefs {
    final manager = $$PurchasesTableTableManager(
      $_db,
      $_db.purchases,
    ).filter((f) => f.supplierId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_purchasesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SuppliersTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxId => $composableBuilder(
    column: $table.taxId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> purchasesRefs(
    Expression<bool> Function($$PurchasesTableFilterComposer f) f,
  ) {
    final $$PurchasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableFilterComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SuppliersTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxId => $composableBuilder(
    column: $table.taxId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SuppliersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get taxId =>
      $composableBuilder(column: $table.taxId, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> purchasesRefs<T extends Object>(
    Expression<T> Function($$PurchasesTableAnnotationComposer a) f,
  ) {
    final $$PurchasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableAnnotationComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SuppliersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuppliersTable,
          Supplier,
          $$SuppliersTableFilterComposer,
          $$SuppliersTableOrderingComposer,
          $$SuppliersTableAnnotationComposer,
          $$SuppliersTableCreateCompanionBuilder,
          $$SuppliersTableUpdateCompanionBuilder,
          (Supplier, $$SuppliersTableReferences),
          Supplier,
          PrefetchHooks Function({bool purchasesRefs})
        > {
  $$SuppliersTableTableManager(_$AppDatabase db, $SuppliersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> taxId = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion(
                id: id,
                name: name,
                taxId: taxId,
                phone: phone,
                email: email,
                address: address,
                notes: notes,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> taxId = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion.insert(
                id: id,
                name: name,
                taxId: taxId,
                phone: phone,
                email: email,
                address: address,
                notes: notes,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SuppliersTable, Supplier>(table),
                  $$SuppliersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({purchasesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (purchasesRefs) db.purchases],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (purchasesRefs)
                    await $_getPrefetchedDataByColumns<
                      Supplier,
                      $SuppliersTable,
                      Purchase,
                      $PurchasesTable
                    >(
                      currentTable: table,
                      referencedTable: $$SuppliersTableReferences
                          ._purchasesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SuppliersTableReferences(
                            db,
                            table,
                            p0,
                          ).purchasesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'supplier_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SuppliersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuppliersTable,
      Supplier,
      $$SuppliersTableFilterComposer,
      $$SuppliersTableOrderingComposer,
      $$SuppliersTableAnnotationComposer,
      $$SuppliersTableCreateCompanionBuilder,
      $$SuppliersTableUpdateCompanionBuilder,
      (Supplier, $$SuppliersTableReferences),
      Supplier,
      PrefetchHooks Function({bool purchasesRefs})
    >;
typedef $$ExchangeRatesTableCreateCompanionBuilder =
    ExchangeRatesCompanion Function({
      required String id,
      required String currencyCode,
      required String rateToBase,
      required DateTime effectiveAt,
      Value<String?> createdByUserId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$ExchangeRatesTableUpdateCompanionBuilder =
    ExchangeRatesCompanion Function({
      Value<String> id,
      Value<String> currencyCode,
      Value<String> rateToBase,
      Value<DateTime> effectiveAt,
      Value<String?> createdByUserId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ExchangeRatesTableReferences
    extends BaseReferences<_$AppDatabase, $ExchangeRatesTable, ExchangeRate> {
  $$ExchangeRatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CurrenciesTable _currencyCodeTable(_$AppDatabase db) => db.currencies
      .createAlias('exchange_rates__currency_code__currencies__code');

  $$CurrenciesTableProcessedTableManager get currencyCode {
    final $_column = $_itemColumn<String>('currency_code')!;

    final manager = $$CurrenciesTableTableManager(
      $_db,
      $_db.currencies,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currencyCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExchangeRatesTableFilterComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rateToBase => $composableBuilder(
    column: $table.rateToBase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get effectiveAt => $composableBuilder(
    column: $table.effectiveAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CurrenciesTableFilterComposer get currencyCode {
    final $$CurrenciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableFilterComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExchangeRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rateToBase => $composableBuilder(
    column: $table.rateToBase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get effectiveAt => $composableBuilder(
    column: $table.effectiveAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CurrenciesTableOrderingComposer get currencyCode {
    final $$CurrenciesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableOrderingComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExchangeRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rateToBase => $composableBuilder(
    column: $table.rateToBase,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get effectiveAt => $composableBuilder(
    column: $table.effectiveAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CurrenciesTableAnnotationComposer get currencyCode {
    final $$CurrenciesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableAnnotationComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExchangeRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExchangeRatesTable,
          ExchangeRate,
          $$ExchangeRatesTableFilterComposer,
          $$ExchangeRatesTableOrderingComposer,
          $$ExchangeRatesTableAnnotationComposer,
          $$ExchangeRatesTableCreateCompanionBuilder,
          $$ExchangeRatesTableUpdateCompanionBuilder,
          (ExchangeRate, $$ExchangeRatesTableReferences),
          ExchangeRate,
          PrefetchHooks Function({bool currencyCode})
        > {
  $$ExchangeRatesTableTableManager(_$AppDatabase db, $ExchangeRatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExchangeRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExchangeRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExchangeRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> rateToBase = const Value.absent(),
                Value<DateTime> effectiveAt = const Value.absent(),
                Value<String?> createdByUserId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExchangeRatesCompanion(
                id: id,
                currencyCode: currencyCode,
                rateToBase: rateToBase,
                effectiveAt: effectiveAt,
                createdByUserId: createdByUserId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String currencyCode,
                required String rateToBase,
                required DateTime effectiveAt,
                Value<String?> createdByUserId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExchangeRatesCompanion.insert(
                id: id,
                currencyCode: currencyCode,
                rateToBase: rateToBase,
                effectiveAt: effectiveAt,
                createdByUserId: createdByUserId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExchangeRatesTable, ExchangeRate>(table),
                  $$ExchangeRatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({currencyCode = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (currencyCode) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.currencyCode,
                        referencedTable: $$ExchangeRatesTableReferences
                            ._currencyCodeTable(db),
                        referencedColumn: $$ExchangeRatesTableReferences
                            ._currencyCodeTable(db)
                            .code,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExchangeRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExchangeRatesTable,
      ExchangeRate,
      $$ExchangeRatesTableFilterComposer,
      $$ExchangeRatesTableOrderingComposer,
      $$ExchangeRatesTableAnnotationComposer,
      $$ExchangeRatesTableCreateCompanionBuilder,
      $$ExchangeRatesTableUpdateCompanionBuilder,
      (ExchangeRate, $$ExchangeRatesTableReferences),
      ExchangeRate,
      PrefetchHooks Function({bool currencyCode})
    >;
typedef $$PurchasesTableCreateCompanionBuilder = PurchasesCompanion Function({
  required String id,
  required String supplierId,
  Value<String?> documentNumber,
  required DateTime purchaseDate,
  required String currencyCode,
  required String exchangeRateToBaseSnapshot,
  required int subtotalMinorUnits,
  Value<int> discountMinorUnits,
  Value<int> taxMinorUnits,
  required int totalMinorUnits,
  Value<String?> notes,
  Value<String> status,
  Value<DateTime?> confirmedAt,
  Value<DateTime?> cancelledAt,
  Value<String?> cancellationReason,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$PurchasesTableUpdateCompanionBuilder = PurchasesCompanion Function({
  Value<String> id,
  Value<String> supplierId,
  Value<String?> documentNumber,
  Value<DateTime> purchaseDate,
  Value<String> currencyCode,
  Value<String> exchangeRateToBaseSnapshot,
  Value<int> subtotalMinorUnits,
  Value<int> discountMinorUnits,
  Value<int> taxMinorUnits,
  Value<int> totalMinorUnits,
  Value<String?> notes,
  Value<String> status,
  Value<DateTime?> confirmedAt,
  Value<DateTime?> cancelledAt,
  Value<String?> cancellationReason,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$PurchasesTableReferences
    extends BaseReferences<_$AppDatabase, $PurchasesTable, Purchase> {
  $$PurchasesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SuppliersTable _supplierIdTable(_$AppDatabase db) =>
      db.suppliers.createAlias('purchases__supplier_id__suppliers__id');

  $$SuppliersTableProcessedTableManager get supplierId {
    final $_column = $_itemColumn<String>('supplier_id')!;

    final manager = $$SuppliersTableTableManager(
      $_db,
      $_db.suppliers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CurrenciesTable _currencyCodeTable(_$AppDatabase db) =>
      db.currencies.createAlias('purchases__currency_code__currencies__code');

  $$CurrenciesTableProcessedTableManager get currencyCode {
    final $_column = $_itemColumn<String>('currency_code')!;

    final manager = $$CurrenciesTableTableManager(
      $_db,
      $_db.currencies,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currencyCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PurchaseDetailsTable, List<PurchaseDetail>>
  _purchaseDetailsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.purchaseDetails,
    aliasName: 'purchases__id__purchase_details__purchase_id',
  );

  $$PurchaseDetailsTableProcessedTableManager get purchaseDetailsRefs {
    final manager = $$PurchaseDetailsTableTableManager(
      $_db,
      $_db.purchaseDetails,
    ).filter((f) => f.purchaseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _purchaseDetailsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PurchaseReceiptsTable, List<PurchaseReceipt>>
  _purchaseReceiptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.purchaseReceipts,
    aliasName: 'purchases__id__purchase_receipts__purchase_id',
  );

  $$PurchaseReceiptsTableProcessedTableManager get purchaseReceiptsRefs {
    final manager = $$PurchaseReceiptsTableTableManager(
      $_db,
      $_db.purchaseReceipts,
    ).filter((f) => f.purchaseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _purchaseReceiptsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SupplierPaymentsTable, List<SupplierPayment>>
  _supplierPaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.supplierPayments,
    aliasName: 'purchases__id__supplier_payments__purchase_id',
  );

  $$SupplierPaymentsTableProcessedTableManager get supplierPaymentsRefs {
    final manager = $$SupplierPaymentsTableTableManager(
      $_db,
      $_db.supplierPayments,
    ).filter((f) => f.purchaseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supplierPaymentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PurchasesTableFilterComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentNumber => $composableBuilder(
    column: $table.documentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exchangeRateToBaseSnapshot => $composableBuilder(
    column: $table.exchangeRateToBaseSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subtotalMinorUnits => $composableBuilder(
    column: $table.subtotalMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountMinorUnits => $composableBuilder(
    column: $table.discountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taxMinorUnits => $composableBuilder(
    column: $table.taxMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMinorUnits => $composableBuilder(
    column: $table.totalMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cancellationReason => $composableBuilder(
    column: $table.cancellationReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SuppliersTableFilterComposer get supplierId {
    final $$SuppliersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableFilterComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CurrenciesTableFilterComposer get currencyCode {
    final $$CurrenciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableFilterComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> purchaseDetailsRefs(
    Expression<bool> Function($$PurchaseDetailsTableFilterComposer f) f,
  ) {
    final $$PurchaseDetailsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseDetails,
      getReferencedColumn: (t) => t.purchaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseDetailsTableFilterComposer(
            $db: $db,
            $table: $db.purchaseDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> purchaseReceiptsRefs(
    Expression<bool> Function($$PurchaseReceiptsTableFilterComposer f) f,
  ) {
    final $$PurchaseReceiptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseReceipts,
      getReferencedColumn: (t) => t.purchaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseReceiptsTableFilterComposer(
            $db: $db,
            $table: $db.purchaseReceipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> supplierPaymentsRefs(
    Expression<bool> Function($$SupplierPaymentsTableFilterComposer f) f,
  ) {
    final $$SupplierPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierPayments,
      getReferencedColumn: (t) => t.purchaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.supplierPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PurchasesTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentNumber => $composableBuilder(
    column: $table.documentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exchangeRateToBaseSnapshot => $composableBuilder(
    column: $table.exchangeRateToBaseSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subtotalMinorUnits => $composableBuilder(
    column: $table.subtotalMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountMinorUnits => $composableBuilder(
    column: $table.discountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taxMinorUnits => $composableBuilder(
    column: $table.taxMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMinorUnits => $composableBuilder(
    column: $table.totalMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cancellationReason => $composableBuilder(
    column: $table.cancellationReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SuppliersTableOrderingComposer get supplierId {
    final $$SuppliersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableOrderingComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CurrenciesTableOrderingComposer get currencyCode {
    final $$CurrenciesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableOrderingComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get documentNumber => $composableBuilder(
    column: $table.documentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exchangeRateToBaseSnapshot => $composableBuilder(
    column: $table.exchangeRateToBaseSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get subtotalMinorUnits => $composableBuilder(
    column: $table.subtotalMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discountMinorUnits => $composableBuilder(
    column: $table.discountMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get taxMinorUnits => $composableBuilder(
    column: $table.taxMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalMinorUnits => $composableBuilder(
    column: $table.totalMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cancellationReason => $composableBuilder(
    column: $table.cancellationReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SuppliersTableAnnotationComposer get supplierId {
    final $$SuppliersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableAnnotationComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CurrenciesTableAnnotationComposer get currencyCode {
    final $$CurrenciesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableAnnotationComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> purchaseDetailsRefs<T extends Object>(
    Expression<T> Function($$PurchaseDetailsTableAnnotationComposer a) f,
  ) {
    final $$PurchaseDetailsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseDetails,
      getReferencedColumn: (t) => t.purchaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseDetailsTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> purchaseReceiptsRefs<T extends Object>(
    Expression<T> Function($$PurchaseReceiptsTableAnnotationComposer a) f,
  ) {
    final $$PurchaseReceiptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseReceipts,
      getReferencedColumn: (t) => t.purchaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseReceiptsTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseReceipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> supplierPaymentsRefs<T extends Object>(
    Expression<T> Function($$SupplierPaymentsTableAnnotationComposer a) f,
  ) {
    final $$SupplierPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierPayments,
      getReferencedColumn: (t) => t.purchaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PurchasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchasesTable,
          Purchase,
          $$PurchasesTableFilterComposer,
          $$PurchasesTableOrderingComposer,
          $$PurchasesTableAnnotationComposer,
          $$PurchasesTableCreateCompanionBuilder,
          $$PurchasesTableUpdateCompanionBuilder,
          (Purchase, $$PurchasesTableReferences),
          Purchase,
          PrefetchHooks Function({
            bool supplierId,
            bool currencyCode,
            bool purchaseDetailsRefs,
            bool purchaseReceiptsRefs,
            bool supplierPaymentsRefs,
          })
        > {
  $$PurchasesTableTableManager(_$AppDatabase db, $PurchasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> supplierId = const Value.absent(),
                Value<String?> documentNumber = const Value.absent(),
                Value<DateTime> purchaseDate = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> exchangeRateToBaseSnapshot = const Value.absent(),
                Value<int> subtotalMinorUnits = const Value.absent(),
                Value<int> discountMinorUnits = const Value.absent(),
                Value<int> taxMinorUnits = const Value.absent(),
                Value<int> totalMinorUnits = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> confirmedAt = const Value.absent(),
                Value<DateTime?> cancelledAt = const Value.absent(),
                Value<String?> cancellationReason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchasesCompanion(
                id: id,
                supplierId: supplierId,
                documentNumber: documentNumber,
                purchaseDate: purchaseDate,
                currencyCode: currencyCode,
                exchangeRateToBaseSnapshot: exchangeRateToBaseSnapshot,
                subtotalMinorUnits: subtotalMinorUnits,
                discountMinorUnits: discountMinorUnits,
                taxMinorUnits: taxMinorUnits,
                totalMinorUnits: totalMinorUnits,
                notes: notes,
                status: status,
                confirmedAt: confirmedAt,
                cancelledAt: cancelledAt,
                cancellationReason: cancellationReason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String supplierId,
                Value<String?> documentNumber = const Value.absent(),
                required DateTime purchaseDate,
                required String currencyCode,
                required String exchangeRateToBaseSnapshot,
                required int subtotalMinorUnits,
                Value<int> discountMinorUnits = const Value.absent(),
                Value<int> taxMinorUnits = const Value.absent(),
                required int totalMinorUnits,
                Value<String?> notes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> confirmedAt = const Value.absent(),
                Value<DateTime?> cancelledAt = const Value.absent(),
                Value<String?> cancellationReason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchasesCompanion.insert(
                id: id,
                supplierId: supplierId,
                documentNumber: documentNumber,
                purchaseDate: purchaseDate,
                currencyCode: currencyCode,
                exchangeRateToBaseSnapshot: exchangeRateToBaseSnapshot,
                subtotalMinorUnits: subtotalMinorUnits,
                discountMinorUnits: discountMinorUnits,
                taxMinorUnits: taxMinorUnits,
                totalMinorUnits: totalMinorUnits,
                notes: notes,
                status: status,
                confirmedAt: confirmedAt,
                cancelledAt: cancelledAt,
                cancellationReason: cancellationReason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PurchasesTable, Purchase>(table),
                  $$PurchasesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                supplierId = false,
                currencyCode = false,
                purchaseDetailsRefs = false,
                purchaseReceiptsRefs = false,
                supplierPaymentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (purchaseDetailsRefs) db.purchaseDetails,
                    if (purchaseReceiptsRefs) db.purchaseReceipts,
                    if (supplierPaymentsRefs) db.supplierPayments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (supplierId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.supplierId,
                            referencedTable: $$PurchasesTableReferences
                                ._supplierIdTable(db),
                            referencedColumn: $$PurchasesTableReferences
                                ._supplierIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (currencyCode) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.currencyCode,
                            referencedTable: $$PurchasesTableReferences
                                ._currencyCodeTable(db),
                            referencedColumn: $$PurchasesTableReferences
                                ._currencyCodeTable(db)
                                .code,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (purchaseDetailsRefs)
                        await $_getPrefetchedDataByColumns<
                          Purchase,
                          $PurchasesTable,
                          PurchaseDetail,
                          $PurchaseDetailsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PurchasesTableReferences
                              ._purchaseDetailsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PurchasesTableReferences(
                                db,
                                table,
                                p0,
                              ).purchaseDetailsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'purchase_id',
                          typedResults: items,
                        ),
                      if (purchaseReceiptsRefs)
                        await $_getPrefetchedDataByColumns<
                          Purchase,
                          $PurchasesTable,
                          PurchaseReceipt,
                          $PurchaseReceiptsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PurchasesTableReferences
                              ._purchaseReceiptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PurchasesTableReferences(
                                db,
                                table,
                                p0,
                              ).purchaseReceiptsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'purchase_id',
                          typedResults: items,
                        ),
                      if (supplierPaymentsRefs)
                        await $_getPrefetchedDataByColumns<
                          Purchase,
                          $PurchasesTable,
                          SupplierPayment,
                          $SupplierPaymentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PurchasesTableReferences
                              ._supplierPaymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PurchasesTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierPaymentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'purchase_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PurchasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchasesTable,
      Purchase,
      $$PurchasesTableFilterComposer,
      $$PurchasesTableOrderingComposer,
      $$PurchasesTableAnnotationComposer,
      $$PurchasesTableCreateCompanionBuilder,
      $$PurchasesTableUpdateCompanionBuilder,
      (Purchase, $$PurchasesTableReferences),
      Purchase,
      PrefetchHooks Function({
        bool supplierId,
        bool currencyCode,
        bool purchaseDetailsRefs,
        bool purchaseReceiptsRefs,
        bool supplierPaymentsRefs,
      })
    >;
typedef $$PurchaseDetailsTableCreateCompanionBuilder =
    PurchaseDetailsCompanion Function({
      required String id,
      required String purchaseId,
      required String productId,
      required String skuSnapshot,
      required String productNameSnapshot,
      required String unitSnapshot,
      required int quantityMilliUnits,
      required int unitCostMinorUnits,
      Value<int> discountMinorUnits,
      Value<String> discountType,
      Value<String?> discountRate,
      Value<int> taxMinorUnits,
      Value<String> taxType,
      Value<String?> taxRate,
      required int totalMinorUnits,
      Value<int> rowid,
    });
typedef $$PurchaseDetailsTableUpdateCompanionBuilder =
    PurchaseDetailsCompanion Function({
      Value<String> id,
      Value<String> purchaseId,
      Value<String> productId,
      Value<String> skuSnapshot,
      Value<String> productNameSnapshot,
      Value<String> unitSnapshot,
      Value<int> quantityMilliUnits,
      Value<int> unitCostMinorUnits,
      Value<int> discountMinorUnits,
      Value<String> discountType,
      Value<String?> discountRate,
      Value<int> taxMinorUnits,
      Value<String> taxType,
      Value<String?> taxRate,
      Value<int> totalMinorUnits,
      Value<int> rowid,
    });

final class $$PurchaseDetailsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PurchaseDetailsTable, PurchaseDetail> {
  $$PurchaseDetailsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PurchasesTable _purchaseIdTable(_$AppDatabase db) =>
      db.purchases.createAlias('purchase_details__purchase_id__purchases__id');

  $$PurchasesTableProcessedTableManager get purchaseId {
    final $_column = $_itemColumn<String>('purchase_id')!;

    final manager = $$PurchasesTableTableManager(
      $_db,
      $_db.purchases,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('purchase_details__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $PurchaseReceiptDetailsTable,
    List<PurchaseReceiptDetail>
  >
  _purchaseReceiptDetailsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.purchaseReceiptDetails,
    aliasName:
        'purchase_details__id__purchase_receipt_details__purchase_detail_id',
  );

  $$PurchaseReceiptDetailsTableProcessedTableManager
  get purchaseReceiptDetailsRefs {
    final manager =
        $$PurchaseReceiptDetailsTableTableManager(
          $_db,
          $_db.purchaseReceiptDetails,
        ).filter(
          (f) => f.purchaseDetailId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _purchaseReceiptDetailsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PurchaseDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseDetailsTable> {
  $$PurchaseDetailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skuSnapshot => $composableBuilder(
    column: $table.skuSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitSnapshot => $composableBuilder(
    column: $table.unitSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityMilliUnits => $composableBuilder(
    column: $table.quantityMilliUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitCostMinorUnits => $composableBuilder(
    column: $table.unitCostMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountMinorUnits => $composableBuilder(
    column: $table.discountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discountRate => $composableBuilder(
    column: $table.discountRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taxMinorUnits => $composableBuilder(
    column: $table.taxMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxType => $composableBuilder(
    column: $table.taxType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxRate => $composableBuilder(
    column: $table.taxRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMinorUnits => $composableBuilder(
    column: $table.totalMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  $$PurchasesTableFilterComposer get purchaseId {
    final $$PurchasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableFilterComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> purchaseReceiptDetailsRefs(
    Expression<bool> Function($$PurchaseReceiptDetailsTableFilterComposer f) f,
  ) {
    final $$PurchaseReceiptDetailsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.purchaseReceiptDetails,
          getReferencedColumn: (t) => t.purchaseDetailId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PurchaseReceiptDetailsTableFilterComposer(
                $db: $db,
                $table: $db.purchaseReceiptDetails,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PurchaseDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseDetailsTable> {
  $$PurchaseDetailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skuSnapshot => $composableBuilder(
    column: $table.skuSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitSnapshot => $composableBuilder(
    column: $table.unitSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityMilliUnits => $composableBuilder(
    column: $table.quantityMilliUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitCostMinorUnits => $composableBuilder(
    column: $table.unitCostMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountMinorUnits => $composableBuilder(
    column: $table.discountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discountRate => $composableBuilder(
    column: $table.discountRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taxMinorUnits => $composableBuilder(
    column: $table.taxMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxType => $composableBuilder(
    column: $table.taxType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxRate => $composableBuilder(
    column: $table.taxRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMinorUnits => $composableBuilder(
    column: $table.totalMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  $$PurchasesTableOrderingComposer get purchaseId {
    final $$PurchasesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableOrderingComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseDetailsTable> {
  $$PurchaseDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get skuSnapshot => $composableBuilder(
    column: $table.skuSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitSnapshot => $composableBuilder(
    column: $table.unitSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityMilliUnits => $composableBuilder(
    column: $table.quantityMilliUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitCostMinorUnits => $composableBuilder(
    column: $table.unitCostMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discountMinorUnits => $composableBuilder(
    column: $table.discountMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discountRate => $composableBuilder(
    column: $table.discountRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get taxMinorUnits => $composableBuilder(
    column: $table.taxMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taxType =>
      $composableBuilder(column: $table.taxType, builder: (column) => column);

  GeneratedColumn<String> get taxRate =>
      $composableBuilder(column: $table.taxRate, builder: (column) => column);

  GeneratedColumn<int> get totalMinorUnits => $composableBuilder(
    column: $table.totalMinorUnits,
    builder: (column) => column,
  );

  $$PurchasesTableAnnotationComposer get purchaseId {
    final $$PurchasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableAnnotationComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> purchaseReceiptDetailsRefs<T extends Object>(
    Expression<T> Function($$PurchaseReceiptDetailsTableAnnotationComposer a) f,
  ) {
    final $$PurchaseReceiptDetailsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.purchaseReceiptDetails,
          getReferencedColumn: (t) => t.purchaseDetailId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PurchaseReceiptDetailsTableAnnotationComposer(
                $db: $db,
                $table: $db.purchaseReceiptDetails,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PurchaseDetailsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchaseDetailsTable,
          PurchaseDetail,
          $$PurchaseDetailsTableFilterComposer,
          $$PurchaseDetailsTableOrderingComposer,
          $$PurchaseDetailsTableAnnotationComposer,
          $$PurchaseDetailsTableCreateCompanionBuilder,
          $$PurchaseDetailsTableUpdateCompanionBuilder,
          (PurchaseDetail, $$PurchaseDetailsTableReferences),
          PurchaseDetail,
          PrefetchHooks Function({
            bool purchaseId,
            bool productId,
            bool purchaseReceiptDetailsRefs,
          })
        > {
  $$PurchaseDetailsTableTableManager(
    _$AppDatabase db,
    $PurchaseDetailsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseDetailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseDetailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseDetailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> purchaseId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> skuSnapshot = const Value.absent(),
                Value<String> productNameSnapshot = const Value.absent(),
                Value<String> unitSnapshot = const Value.absent(),
                Value<int> quantityMilliUnits = const Value.absent(),
                Value<int> unitCostMinorUnits = const Value.absent(),
                Value<int> discountMinorUnits = const Value.absent(),
                Value<String> discountType = const Value.absent(),
                Value<String?> discountRate = const Value.absent(),
                Value<int> taxMinorUnits = const Value.absent(),
                Value<String> taxType = const Value.absent(),
                Value<String?> taxRate = const Value.absent(),
                Value<int> totalMinorUnits = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseDetailsCompanion(
                id: id,
                purchaseId: purchaseId,
                productId: productId,
                skuSnapshot: skuSnapshot,
                productNameSnapshot: productNameSnapshot,
                unitSnapshot: unitSnapshot,
                quantityMilliUnits: quantityMilliUnits,
                unitCostMinorUnits: unitCostMinorUnits,
                discountMinorUnits: discountMinorUnits,
                discountType: discountType,
                discountRate: discountRate,
                taxMinorUnits: taxMinorUnits,
                taxType: taxType,
                taxRate: taxRate,
                totalMinorUnits: totalMinorUnits,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String purchaseId,
                required String productId,
                required String skuSnapshot,
                required String productNameSnapshot,
                required String unitSnapshot,
                required int quantityMilliUnits,
                required int unitCostMinorUnits,
                Value<int> discountMinorUnits = const Value.absent(),
                Value<String> discountType = const Value.absent(),
                Value<String?> discountRate = const Value.absent(),
                Value<int> taxMinorUnits = const Value.absent(),
                Value<String> taxType = const Value.absent(),
                Value<String?> taxRate = const Value.absent(),
                required int totalMinorUnits,
                Value<int> rowid = const Value.absent(),
              }) => PurchaseDetailsCompanion.insert(
                id: id,
                purchaseId: purchaseId,
                productId: productId,
                skuSnapshot: skuSnapshot,
                productNameSnapshot: productNameSnapshot,
                unitSnapshot: unitSnapshot,
                quantityMilliUnits: quantityMilliUnits,
                unitCostMinorUnits: unitCostMinorUnits,
                discountMinorUnits: discountMinorUnits,
                discountType: discountType,
                discountRate: discountRate,
                taxMinorUnits: taxMinorUnits,
                taxType: taxType,
                taxRate: taxRate,
                totalMinorUnits: totalMinorUnits,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PurchaseDetailsTable, PurchaseDetail>(table),
                  $$PurchaseDetailsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                purchaseId = false,
                productId = false,
                purchaseReceiptDetailsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (purchaseReceiptDetailsRefs) db.purchaseReceiptDetails,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (purchaseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.purchaseId,
                            referencedTable: $$PurchaseDetailsTableReferences
                                ._purchaseIdTable(db),
                            referencedColumn: $$PurchaseDetailsTableReferences
                                ._purchaseIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (productId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.productId,
                            referencedTable: $$PurchaseDetailsTableReferences
                                ._productIdTable(db),
                            referencedColumn: $$PurchaseDetailsTableReferences
                                ._productIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (purchaseReceiptDetailsRefs)
                        await $_getPrefetchedDataByColumns<
                          PurchaseDetail,
                          $PurchaseDetailsTable,
                          PurchaseReceiptDetail,
                          $PurchaseReceiptDetailsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PurchaseDetailsTableReferences
                              ._purchaseReceiptDetailsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PurchaseDetailsTableReferences(
                                db,
                                table,
                                p0,
                              ).purchaseReceiptDetailsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'purchase_detail_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PurchaseDetailsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchaseDetailsTable,
      PurchaseDetail,
      $$PurchaseDetailsTableFilterComposer,
      $$PurchaseDetailsTableOrderingComposer,
      $$PurchaseDetailsTableAnnotationComposer,
      $$PurchaseDetailsTableCreateCompanionBuilder,
      $$PurchaseDetailsTableUpdateCompanionBuilder,
      (PurchaseDetail, $$PurchaseDetailsTableReferences),
      PurchaseDetail,
      PrefetchHooks Function({
        bool purchaseId,
        bool productId,
        bool purchaseReceiptDetailsRefs,
      })
    >;
typedef $$PurchaseReceiptsTableCreateCompanionBuilder =
    PurchaseReceiptsCompanion Function({
      required String id,
      required String purchaseId,
      required DateTime receivedAt,
      Value<String?> reference,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$PurchaseReceiptsTableUpdateCompanionBuilder =
    PurchaseReceiptsCompanion Function({
      Value<String> id,
      Value<String> purchaseId,
      Value<DateTime> receivedAt,
      Value<String?> reference,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PurchaseReceiptsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PurchaseReceiptsTable, PurchaseReceipt> {
  $$PurchaseReceiptsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PurchasesTable _purchaseIdTable(_$AppDatabase db) =>
      db.purchases.createAlias('purchase_receipts__purchase_id__purchases__id');

  $$PurchasesTableProcessedTableManager get purchaseId {
    final $_column = $_itemColumn<String>('purchase_id')!;

    final manager = $$PurchasesTableTableManager(
      $_db,
      $_db.purchases,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $PurchaseReceiptDetailsTable,
    List<PurchaseReceiptDetail>
  >
  _purchaseReceiptDetailsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.purchaseReceiptDetails,
        aliasName:
            'purchase_receipts__id__purchase_receipt_details__receipt_id',
      );

  $$PurchaseReceiptDetailsTableProcessedTableManager
  get purchaseReceiptDetailsRefs {
    final manager = $$PurchaseReceiptDetailsTableTableManager(
      $_db,
      $_db.purchaseReceiptDetails,
    ).filter((f) => f.receiptId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _purchaseReceiptDetailsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PurchaseReceiptsTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseReceiptsTable> {
  $$PurchaseReceiptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PurchasesTableFilterComposer get purchaseId {
    final $$PurchasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableFilterComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> purchaseReceiptDetailsRefs(
    Expression<bool> Function($$PurchaseReceiptDetailsTableFilterComposer f) f,
  ) {
    final $$PurchaseReceiptDetailsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.purchaseReceiptDetails,
          getReferencedColumn: (t) => t.receiptId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PurchaseReceiptDetailsTableFilterComposer(
                $db: $db,
                $table: $db.purchaseReceiptDetails,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PurchaseReceiptsTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseReceiptsTable> {
  $$PurchaseReceiptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PurchasesTableOrderingComposer get purchaseId {
    final $$PurchasesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableOrderingComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseReceiptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseReceiptsTable> {
  $$PurchaseReceiptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PurchasesTableAnnotationComposer get purchaseId {
    final $$PurchasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableAnnotationComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> purchaseReceiptDetailsRefs<T extends Object>(
    Expression<T> Function($$PurchaseReceiptDetailsTableAnnotationComposer a) f,
  ) {
    final $$PurchaseReceiptDetailsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.purchaseReceiptDetails,
          getReferencedColumn: (t) => t.receiptId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PurchaseReceiptDetailsTableAnnotationComposer(
                $db: $db,
                $table: $db.purchaseReceiptDetails,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PurchaseReceiptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchaseReceiptsTable,
          PurchaseReceipt,
          $$PurchaseReceiptsTableFilterComposer,
          $$PurchaseReceiptsTableOrderingComposer,
          $$PurchaseReceiptsTableAnnotationComposer,
          $$PurchaseReceiptsTableCreateCompanionBuilder,
          $$PurchaseReceiptsTableUpdateCompanionBuilder,
          (PurchaseReceipt, $$PurchaseReceiptsTableReferences),
          PurchaseReceipt,
          PrefetchHooks Function({
            bool purchaseId,
            bool purchaseReceiptDetailsRefs,
          })
        > {
  $$PurchaseReceiptsTableTableManager(
    _$AppDatabase db,
    $PurchaseReceiptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseReceiptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseReceiptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseReceiptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> purchaseId = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseReceiptsCompanion(
                id: id,
                purchaseId: purchaseId,
                receivedAt: receivedAt,
                reference: reference,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String purchaseId,
                required DateTime receivedAt,
                Value<String?> reference = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseReceiptsCompanion.insert(
                id: id,
                purchaseId: purchaseId,
                receivedAt: receivedAt,
                reference: reference,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PurchaseReceiptsTable, PurchaseReceipt>(table),
                  $$PurchaseReceiptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({purchaseId = false, purchaseReceiptDetailsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (purchaseReceiptDetailsRefs) db.purchaseReceiptDetails,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (purchaseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.purchaseId,
                            referencedTable: $$PurchaseReceiptsTableReferences
                                ._purchaseIdTable(db),
                            referencedColumn: $$PurchaseReceiptsTableReferences
                                ._purchaseIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (purchaseReceiptDetailsRefs)
                        await $_getPrefetchedDataByColumns<
                          PurchaseReceipt,
                          $PurchaseReceiptsTable,
                          PurchaseReceiptDetail,
                          $PurchaseReceiptDetailsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PurchaseReceiptsTableReferences
                              ._purchaseReceiptDetailsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PurchaseReceiptsTableReferences(
                                db,
                                table,
                                p0,
                              ).purchaseReceiptDetailsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'receipt_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PurchaseReceiptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchaseReceiptsTable,
      PurchaseReceipt,
      $$PurchaseReceiptsTableFilterComposer,
      $$PurchaseReceiptsTableOrderingComposer,
      $$PurchaseReceiptsTableAnnotationComposer,
      $$PurchaseReceiptsTableCreateCompanionBuilder,
      $$PurchaseReceiptsTableUpdateCompanionBuilder,
      (PurchaseReceipt, $$PurchaseReceiptsTableReferences),
      PurchaseReceipt,
      PrefetchHooks Function({bool purchaseId, bool purchaseReceiptDetailsRefs})
    >;
typedef $$PurchaseReceiptDetailsTableCreateCompanionBuilder =
    PurchaseReceiptDetailsCompanion Function({
      required String id,
      required String receiptId,
      required String purchaseDetailId,
      required int quantityMilliUnits,
      Value<String?> inventoryMovementId,
      Value<int> rowid,
    });
typedef $$PurchaseReceiptDetailsTableUpdateCompanionBuilder =
    PurchaseReceiptDetailsCompanion Function({
      Value<String> id,
      Value<String> receiptId,
      Value<String> purchaseDetailId,
      Value<int> quantityMilliUnits,
      Value<String?> inventoryMovementId,
      Value<int> rowid,
    });

final class $$PurchaseReceiptDetailsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PurchaseReceiptDetailsTable,
          PurchaseReceiptDetail
        > {
  $$PurchaseReceiptDetailsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PurchaseReceiptsTable _receiptIdTable(_$AppDatabase db) =>
      db.purchaseReceipts.createAlias(
        'purchase_receipt_details__receipt_id__purchase_receipts__id',
      );

  $$PurchaseReceiptsTableProcessedTableManager get receiptId {
    final $_column = $_itemColumn<String>('receipt_id')!;

    final manager = $$PurchaseReceiptsTableTableManager(
      $_db,
      $_db.purchaseReceipts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_receiptIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PurchaseDetailsTable _purchaseDetailIdTable(_$AppDatabase db) =>
      db.purchaseDetails.createAlias(
        'purchase_receipt_details__purchase_detail_id__purchase_details__id',
      );

  $$PurchaseDetailsTableProcessedTableManager get purchaseDetailId {
    final $_column = $_itemColumn<String>('purchase_detail_id')!;

    final manager = $$PurchaseDetailsTableTableManager(
      $_db,
      $_db.purchaseDetails,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseDetailIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InventoryMovementsTable _inventoryMovementIdTable(
    _$AppDatabase db,
  ) => db.inventoryMovements.createAlias(
    'purchase_receipt_details__inventory_movement_id__inventory_movements__id',
  );

  $$InventoryMovementsTableProcessedTableManager? get inventoryMovementId {
    final $_column = $_itemColumn<String>('inventory_movement_id');
    if ($_column == null) return null;
    final manager = $$InventoryMovementsTableTableManager(
      $_db,
      $_db.inventoryMovements,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_inventoryMovementIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PurchaseReceiptDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseReceiptDetailsTable> {
  $$PurchaseReceiptDetailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityMilliUnits => $composableBuilder(
    column: $table.quantityMilliUnits,
    builder: (column) => ColumnFilters(column),
  );

  $$PurchaseReceiptsTableFilterComposer get receiptId {
    final $$PurchaseReceiptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receiptId,
      referencedTable: $db.purchaseReceipts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseReceiptsTableFilterComposer(
            $db: $db,
            $table: $db.purchaseReceipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PurchaseDetailsTableFilterComposer get purchaseDetailId {
    final $$PurchaseDetailsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseDetailId,
      referencedTable: $db.purchaseDetails,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseDetailsTableFilterComposer(
            $db: $db,
            $table: $db.purchaseDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryMovementsTableFilterComposer get inventoryMovementId {
    final $$InventoryMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inventoryMovementId,
      referencedTable: $db.inventoryMovements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryMovementsTableFilterComposer(
            $db: $db,
            $table: $db.inventoryMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseReceiptDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseReceiptDetailsTable> {
  $$PurchaseReceiptDetailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityMilliUnits => $composableBuilder(
    column: $table.quantityMilliUnits,
    builder: (column) => ColumnOrderings(column),
  );

  $$PurchaseReceiptsTableOrderingComposer get receiptId {
    final $$PurchaseReceiptsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receiptId,
      referencedTable: $db.purchaseReceipts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseReceiptsTableOrderingComposer(
            $db: $db,
            $table: $db.purchaseReceipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PurchaseDetailsTableOrderingComposer get purchaseDetailId {
    final $$PurchaseDetailsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseDetailId,
      referencedTable: $db.purchaseDetails,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseDetailsTableOrderingComposer(
            $db: $db,
            $table: $db.purchaseDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryMovementsTableOrderingComposer get inventoryMovementId {
    final $$InventoryMovementsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inventoryMovementId,
      referencedTable: $db.inventoryMovements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryMovementsTableOrderingComposer(
            $db: $db,
            $table: $db.inventoryMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseReceiptDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseReceiptDetailsTable> {
  $$PurchaseReceiptDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantityMilliUnits => $composableBuilder(
    column: $table.quantityMilliUnits,
    builder: (column) => column,
  );

  $$PurchaseReceiptsTableAnnotationComposer get receiptId {
    final $$PurchaseReceiptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receiptId,
      referencedTable: $db.purchaseReceipts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseReceiptsTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseReceipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PurchaseDetailsTableAnnotationComposer get purchaseDetailId {
    final $$PurchaseDetailsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseDetailId,
      referencedTable: $db.purchaseDetails,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseDetailsTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryMovementsTableAnnotationComposer get inventoryMovementId {
    final $$InventoryMovementsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.inventoryMovementId,
          referencedTable: $db.inventoryMovements,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InventoryMovementsTableAnnotationComposer(
                $db: $db,
                $table: $db.inventoryMovements,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$PurchaseReceiptDetailsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchaseReceiptDetailsTable,
          PurchaseReceiptDetail,
          $$PurchaseReceiptDetailsTableFilterComposer,
          $$PurchaseReceiptDetailsTableOrderingComposer,
          $$PurchaseReceiptDetailsTableAnnotationComposer,
          $$PurchaseReceiptDetailsTableCreateCompanionBuilder,
          $$PurchaseReceiptDetailsTableUpdateCompanionBuilder,
          (PurchaseReceiptDetail, $$PurchaseReceiptDetailsTableReferences),
          PurchaseReceiptDetail,
          PrefetchHooks Function({
            bool receiptId,
            bool purchaseDetailId,
            bool inventoryMovementId,
          })
        > {
  $$PurchaseReceiptDetailsTableTableManager(
    _$AppDatabase db,
    $PurchaseReceiptDetailsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseReceiptDetailsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PurchaseReceiptDetailsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PurchaseReceiptDetailsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> receiptId = const Value.absent(),
                Value<String> purchaseDetailId = const Value.absent(),
                Value<int> quantityMilliUnits = const Value.absent(),
                Value<String?> inventoryMovementId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseReceiptDetailsCompanion(
                id: id,
                receiptId: receiptId,
                purchaseDetailId: purchaseDetailId,
                quantityMilliUnits: quantityMilliUnits,
                inventoryMovementId: inventoryMovementId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String receiptId,
                required String purchaseDetailId,
                required int quantityMilliUnits,
                Value<String?> inventoryMovementId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseReceiptDetailsCompanion.insert(
                id: id,
                receiptId: receiptId,
                purchaseDetailId: purchaseDetailId,
                quantityMilliUnits: quantityMilliUnits,
                inventoryMovementId: inventoryMovementId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $PurchaseReceiptDetailsTable,
                    PurchaseReceiptDetail
                  >(table),
                  $$PurchaseReceiptDetailsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                receiptId = false,
                purchaseDetailId = false,
                inventoryMovementId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (receiptId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.receiptId,
                            referencedTable:
                                $$PurchaseReceiptDetailsTableReferences
                                    ._receiptIdTable(db),
                            referencedColumn:
                                $$PurchaseReceiptDetailsTableReferences
                                    ._receiptIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (purchaseDetailId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.purchaseDetailId,
                            referencedTable:
                                $$PurchaseReceiptDetailsTableReferences
                                    ._purchaseDetailIdTable(db),
                            referencedColumn:
                                $$PurchaseReceiptDetailsTableReferences
                                    ._purchaseDetailIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (inventoryMovementId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.inventoryMovementId,
                            referencedTable:
                                $$PurchaseReceiptDetailsTableReferences
                                    ._inventoryMovementIdTable(db),
                            referencedColumn:
                                $$PurchaseReceiptDetailsTableReferences
                                    ._inventoryMovementIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$PurchaseReceiptDetailsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchaseReceiptDetailsTable,
      PurchaseReceiptDetail,
      $$PurchaseReceiptDetailsTableFilterComposer,
      $$PurchaseReceiptDetailsTableOrderingComposer,
      $$PurchaseReceiptDetailsTableAnnotationComposer,
      $$PurchaseReceiptDetailsTableCreateCompanionBuilder,
      $$PurchaseReceiptDetailsTableUpdateCompanionBuilder,
      (PurchaseReceiptDetail, $$PurchaseReceiptDetailsTableReferences),
      PurchaseReceiptDetail,
      PrefetchHooks Function({
        bool receiptId,
        bool purchaseDetailId,
        bool inventoryMovementId,
      })
    >;
typedef $$SupplierPaymentsTableCreateCompanionBuilder =
    SupplierPaymentsCompanion Function({
      required String id,
      required String purchaseId,
      required int amountMinorUnits,
      required String currencyCode,
      required String exchangeRateToBaseSnapshot,
      required int appliedAmountMinorUnits,
      required DateTime paymentDate,
      required String paymentMethod,
      Value<String?> reference,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$SupplierPaymentsTableUpdateCompanionBuilder =
    SupplierPaymentsCompanion Function({
      Value<String> id,
      Value<String> purchaseId,
      Value<int> amountMinorUnits,
      Value<String> currencyCode,
      Value<String> exchangeRateToBaseSnapshot,
      Value<int> appliedAmountMinorUnits,
      Value<DateTime> paymentDate,
      Value<String> paymentMethod,
      Value<String?> reference,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$SupplierPaymentsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SupplierPaymentsTable, SupplierPayment> {
  $$SupplierPaymentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PurchasesTable _purchaseIdTable(_$AppDatabase db) =>
      db.purchases.createAlias('supplier_payments__purchase_id__purchases__id');

  $$PurchasesTableProcessedTableManager get purchaseId {
    final $_column = $_itemColumn<String>('purchase_id')!;

    final manager = $$PurchasesTableTableManager(
      $_db,
      $_db.purchases,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CurrenciesTable _currencyCodeTable(_$AppDatabase db) => db.currencies
      .createAlias('supplier_payments__currency_code__currencies__code');

  $$CurrenciesTableProcessedTableManager get currencyCode {
    final $_column = $_itemColumn<String>('currency_code')!;

    final manager = $$CurrenciesTableTableManager(
      $_db,
      $_db.currencies,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currencyCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SupplierPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $SupplierPaymentsTable> {
  $$SupplierPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exchangeRateToBaseSnapshot => $composableBuilder(
    column: $table.exchangeRateToBaseSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get appliedAmountMinorUnits => $composableBuilder(
    column: $table.appliedAmountMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PurchasesTableFilterComposer get purchaseId {
    final $$PurchasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableFilterComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CurrenciesTableFilterComposer get currencyCode {
    final $$CurrenciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableFilterComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplierPaymentsTable> {
  $$SupplierPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exchangeRateToBaseSnapshot => $composableBuilder(
    column: $table.exchangeRateToBaseSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get appliedAmountMinorUnits => $composableBuilder(
    column: $table.appliedAmountMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PurchasesTableOrderingComposer get purchaseId {
    final $$PurchasesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableOrderingComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CurrenciesTableOrderingComposer get currencyCode {
    final $$CurrenciesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableOrderingComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplierPaymentsTable> {
  $$SupplierPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMinorUnits => $composableBuilder(
    column: $table.amountMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exchangeRateToBaseSnapshot => $composableBuilder(
    column: $table.exchangeRateToBaseSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get appliedAmountMinorUnits => $composableBuilder(
    column: $table.appliedAmountMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PurchasesTableAnnotationComposer get purchaseId {
    final $$PurchasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableAnnotationComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CurrenciesTableAnnotationComposer get currencyCode {
    final $$CurrenciesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableAnnotationComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupplierPaymentsTable,
          SupplierPayment,
          $$SupplierPaymentsTableFilterComposer,
          $$SupplierPaymentsTableOrderingComposer,
          $$SupplierPaymentsTableAnnotationComposer,
          $$SupplierPaymentsTableCreateCompanionBuilder,
          $$SupplierPaymentsTableUpdateCompanionBuilder,
          (SupplierPayment, $$SupplierPaymentsTableReferences),
          SupplierPayment,
          PrefetchHooks Function({bool purchaseId, bool currencyCode})
        > {
  $$SupplierPaymentsTableTableManager(
    _$AppDatabase db,
    $SupplierPaymentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplierPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplierPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> purchaseId = const Value.absent(),
                Value<int> amountMinorUnits = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> exchangeRateToBaseSnapshot = const Value.absent(),
                Value<int> appliedAmountMinorUnits = const Value.absent(),
                Value<DateTime> paymentDate = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplierPaymentsCompanion(
                id: id,
                purchaseId: purchaseId,
                amountMinorUnits: amountMinorUnits,
                currencyCode: currencyCode,
                exchangeRateToBaseSnapshot: exchangeRateToBaseSnapshot,
                appliedAmountMinorUnits: appliedAmountMinorUnits,
                paymentDate: paymentDate,
                paymentMethod: paymentMethod,
                reference: reference,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String purchaseId,
                required int amountMinorUnits,
                required String currencyCode,
                required String exchangeRateToBaseSnapshot,
                required int appliedAmountMinorUnits,
                required DateTime paymentDate,
                required String paymentMethod,
                Value<String?> reference = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplierPaymentsCompanion.insert(
                id: id,
                purchaseId: purchaseId,
                amountMinorUnits: amountMinorUnits,
                currencyCode: currencyCode,
                exchangeRateToBaseSnapshot: exchangeRateToBaseSnapshot,
                appliedAmountMinorUnits: appliedAmountMinorUnits,
                paymentDate: paymentDate,
                paymentMethod: paymentMethod,
                reference: reference,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SupplierPaymentsTable, SupplierPayment>(table),
                  $$SupplierPaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({purchaseId = false, currencyCode = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (purchaseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.purchaseId,
                        referencedTable: $$SupplierPaymentsTableReferences
                            ._purchaseIdTable(db),
                        referencedColumn: $$SupplierPaymentsTableReferences
                            ._purchaseIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (currencyCode) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.currencyCode,
                        referencedTable: $$SupplierPaymentsTableReferences
                            ._currencyCodeTable(db),
                        referencedColumn: $$SupplierPaymentsTableReferences
                            ._currencyCodeTable(db)
                            .code,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SupplierPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupplierPaymentsTable,
      SupplierPayment,
      $$SupplierPaymentsTableFilterComposer,
      $$SupplierPaymentsTableOrderingComposer,
      $$SupplierPaymentsTableAnnotationComposer,
      $$SupplierPaymentsTableCreateCompanionBuilder,
      $$SupplierPaymentsTableUpdateCompanionBuilder,
      (SupplierPayment, $$SupplierPaymentsTableReferences),
      SupplierPayment,
      PrefetchHooks Function({bool purchaseId, bool currencyCode})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db, _db.currencies);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$ProductPricesTableTableManager get productPrices =>
      $$ProductPricesTableTableManager(_db, _db.productPrices);
  $$InventoryMovementsTableTableManager get inventoryMovements =>
      $$InventoryMovementsTableTableManager(_db, _db.inventoryMovements);
  $$InventoryBalancesTableTableManager get inventoryBalances =>
      $$InventoryBalancesTableTableManager(_db, _db.inventoryBalances);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db, _db.suppliers);
  $$ExchangeRatesTableTableManager get exchangeRates =>
      $$ExchangeRatesTableTableManager(_db, _db.exchangeRates);
  $$PurchasesTableTableManager get purchases =>
      $$PurchasesTableTableManager(_db, _db.purchases);
  $$PurchaseDetailsTableTableManager get purchaseDetails =>
      $$PurchaseDetailsTableTableManager(_db, _db.purchaseDetails);
  $$PurchaseReceiptsTableTableManager get purchaseReceipts =>
      $$PurchaseReceiptsTableTableManager(_db, _db.purchaseReceipts);
  $$PurchaseReceiptDetailsTableTableManager get purchaseReceiptDetails =>
      $$PurchaseReceiptDetailsTableTableManager(
        _db,
        _db.purchaseReceiptDetails,
      );
  $$SupplierPaymentsTableTableManager get supplierPayments =>
      $$SupplierPaymentsTableTableManager(_db, _db.supplierPayments);
}
