// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $NotebooksTable extends Notebooks
    with TableInfo<$NotebooksTable, Notebook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotebooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notebooks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Notebook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
  Notebook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Notebook(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NotebooksTable createAlias(String alias) {
    return $NotebooksTable(attachedDatabase, alias);
  }
}

class Notebook extends DataClass implements Insertable<Notebook> {
  final int id;
  final String name;
  final DateTime createdAt;
  const Notebook({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NotebooksCompanion toCompanion(bool nullToAbsent) {
    return NotebooksCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory Notebook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Notebook(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Notebook copyWith({int? id, String? name, DateTime? createdAt}) => Notebook(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  Notebook copyWithCompanion(NotebooksCompanion data) {
    return Notebook(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Notebook(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notebook &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class NotebooksCompanion extends UpdateCompanion<Notebook> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  const NotebooksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NotebooksCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Notebook> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NotebooksCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
  }) {
    return NotebooksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotebooksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $IndexItemsTable extends IndexItems
    with TableInfo<$IndexItemsTable, IndexItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IndexItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _notebookIdMeta = const VerificationMeta(
    'notebookId',
  );
  @override
  late final GeneratedColumn<int> notebookId = GeneratedColumn<int>(
    'notebook_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notebooks (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 500),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 5000),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extraInfoMeta = const VerificationMeta(
    'extraInfo',
  );
  @override
  late final GeneratedColumn<String> extraInfo = GeneratedColumn<String>(
    'extra_info',
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
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _modifiedAtMeta = const VerificationMeta(
    'modifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> modifiedAt = GeneratedColumn<DateTime>(
    'modified_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    notebookId,
    title,
    description,
    position,
    extraInfo,
    createdAt,
    modifiedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'index_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<IndexItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('notebook_id')) {
      context.handle(
        _notebookIdMeta,
        notebookId.isAcceptableOrUnknown(data['notebook_id']!, _notebookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_notebookIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
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
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('extra_info')) {
      context.handle(
        _extraInfoMeta,
        extraInfo.isAcceptableOrUnknown(data['extra_info']!, _extraInfoMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('modified_at')) {
      context.handle(
        _modifiedAtMeta,
        modifiedAt.isAcceptableOrUnknown(data['modified_at']!, _modifiedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IndexItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IndexItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      notebookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notebook_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      extraInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra_info'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      modifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}modified_at'],
      )!,
    );
  }

  @override
  $IndexItemsTable createAlias(String alias) {
    return $IndexItemsTable(attachedDatabase, alias);
  }
}

class IndexItem extends DataClass implements Insertable<IndexItem> {
  final int id;
  final int notebookId;
  final String? title;
  final String? description;
  final int position;
  final String? extraInfo;
  final DateTime createdAt;
  final DateTime modifiedAt;
  const IndexItem({
    required this.id,
    required this.notebookId,
    this.title,
    this.description,
    required this.position,
    this.extraInfo,
    required this.createdAt,
    required this.modifiedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['notebook_id'] = Variable<int>(notebookId);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || extraInfo != null) {
      map['extra_info'] = Variable<String>(extraInfo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['modified_at'] = Variable<DateTime>(modifiedAt);
    return map;
  }

  IndexItemsCompanion toCompanion(bool nullToAbsent) {
    return IndexItemsCompanion(
      id: Value(id),
      notebookId: Value(notebookId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      position: Value(position),
      extraInfo: extraInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(extraInfo),
      createdAt: Value(createdAt),
      modifiedAt: Value(modifiedAt),
    );
  }

  factory IndexItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IndexItem(
      id: serializer.fromJson<int>(json['id']),
      notebookId: serializer.fromJson<int>(json['notebookId']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      position: serializer.fromJson<int>(json['position']),
      extraInfo: serializer.fromJson<String?>(json['extraInfo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'notebookId': serializer.toJson<int>(notebookId),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'position': serializer.toJson<int>(position),
      'extraInfo': serializer.toJson<String?>(extraInfo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
    };
  }

  IndexItem copyWith({
    int? id,
    int? notebookId,
    Value<String?> title = const Value.absent(),
    Value<String?> description = const Value.absent(),
    int? position,
    Value<String?> extraInfo = const Value.absent(),
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) => IndexItem(
    id: id ?? this.id,
    notebookId: notebookId ?? this.notebookId,
    title: title.present ? title.value : this.title,
    description: description.present ? description.value : this.description,
    position: position ?? this.position,
    extraInfo: extraInfo.present ? extraInfo.value : this.extraInfo,
    createdAt: createdAt ?? this.createdAt,
    modifiedAt: modifiedAt ?? this.modifiedAt,
  );
  IndexItem copyWithCompanion(IndexItemsCompanion data) {
    return IndexItem(
      id: data.id.present ? data.id.value : this.id,
      notebookId: data.notebookId.present
          ? data.notebookId.value
          : this.notebookId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      position: data.position.present ? data.position.value : this.position,
      extraInfo: data.extraInfo.present ? data.extraInfo.value : this.extraInfo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt: data.modifiedAt.present
          ? data.modifiedAt.value
          : this.modifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IndexItem(')
          ..write('id: $id, ')
          ..write('notebookId: $notebookId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('position: $position, ')
          ..write('extraInfo: $extraInfo, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    notebookId,
    title,
    description,
    position,
    extraInfo,
    createdAt,
    modifiedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IndexItem &&
          other.id == this.id &&
          other.notebookId == this.notebookId &&
          other.title == this.title &&
          other.description == this.description &&
          other.position == this.position &&
          other.extraInfo == this.extraInfo &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt);
}

class IndexItemsCompanion extends UpdateCompanion<IndexItem> {
  final Value<int> id;
  final Value<int> notebookId;
  final Value<String?> title;
  final Value<String?> description;
  final Value<int> position;
  final Value<String?> extraInfo;
  final Value<DateTime> createdAt;
  final Value<DateTime> modifiedAt;
  const IndexItemsCompanion({
    this.id = const Value.absent(),
    this.notebookId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.position = const Value.absent(),
    this.extraInfo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
  });
  IndexItemsCompanion.insert({
    this.id = const Value.absent(),
    required int notebookId,
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    required int position,
    this.extraInfo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
  }) : notebookId = Value(notebookId),
       position = Value(position);
  static Insertable<IndexItem> custom({
    Expression<int>? id,
    Expression<int>? notebookId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? position,
    Expression<String>? extraInfo,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? modifiedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (notebookId != null) 'notebook_id': notebookId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (position != null) 'position': position,
      if (extraInfo != null) 'extra_info': extraInfo,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
    });
  }

  IndexItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? notebookId,
    Value<String?>? title,
    Value<String?>? description,
    Value<int>? position,
    Value<String?>? extraInfo,
    Value<DateTime>? createdAt,
    Value<DateTime>? modifiedAt,
  }) {
    return IndexItemsCompanion(
      id: id ?? this.id,
      notebookId: notebookId ?? this.notebookId,
      title: title ?? this.title,
      description: description ?? this.description,
      position: position ?? this.position,
      extraInfo: extraInfo ?? this.extraInfo,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (notebookId.present) {
      map['notebook_id'] = Variable<int>(notebookId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (extraInfo.present) {
      map['extra_info'] = Variable<String>(extraInfo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<DateTime>(modifiedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IndexItemsCompanion(')
          ..write('id: $id, ')
          ..write('notebookId: $notebookId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('position: $position, ')
          ..write('extraInfo: $extraInfo, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt')
          ..write(')'))
        .toString();
  }
}

class $UiPreferencesTable extends UiPreferences
    with TableInfo<$UiPreferencesTable, UiPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UiPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _notebookIdMeta = const VerificationMeta(
    'notebookId',
  );
  @override
  late final GeneratedColumn<int> notebookId = GeneratedColumn<int>(
    'notebook_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notebooks (id)',
    ),
  );
  static const VerificationMeta _preferencesMeta = const VerificationMeta(
    'preferences',
  );
  @override
  late final GeneratedColumn<String> preferences = GeneratedColumn<String>(
    'preferences',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [notebookId, preferences];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ui_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<UiPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('notebook_id')) {
      context.handle(
        _notebookIdMeta,
        notebookId.isAcceptableOrUnknown(data['notebook_id']!, _notebookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_notebookIdMeta);
    }
    if (data.containsKey('preferences')) {
      context.handle(
        _preferencesMeta,
        preferences.isAcceptableOrUnknown(
          data['preferences']!,
          _preferencesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  UiPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UiPreference(
      notebookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notebook_id'],
      )!,
      preferences: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferences'],
      ),
    );
  }

  @override
  $UiPreferencesTable createAlias(String alias) {
    return $UiPreferencesTable(attachedDatabase, alias);
  }
}

class UiPreference extends DataClass implements Insertable<UiPreference> {
  final int notebookId;
  final String? preferences;
  const UiPreference({required this.notebookId, this.preferences});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['notebook_id'] = Variable<int>(notebookId);
    if (!nullToAbsent || preferences != null) {
      map['preferences'] = Variable<String>(preferences);
    }
    return map;
  }

  UiPreferencesCompanion toCompanion(bool nullToAbsent) {
    return UiPreferencesCompanion(
      notebookId: Value(notebookId),
      preferences: preferences == null && nullToAbsent
          ? const Value.absent()
          : Value(preferences),
    );
  }

  factory UiPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UiPreference(
      notebookId: serializer.fromJson<int>(json['notebookId']),
      preferences: serializer.fromJson<String?>(json['preferences']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'notebookId': serializer.toJson<int>(notebookId),
      'preferences': serializer.toJson<String?>(preferences),
    };
  }

  UiPreference copyWith({
    int? notebookId,
    Value<String?> preferences = const Value.absent(),
  }) => UiPreference(
    notebookId: notebookId ?? this.notebookId,
    preferences: preferences.present ? preferences.value : this.preferences,
  );
  UiPreference copyWithCompanion(UiPreferencesCompanion data) {
    return UiPreference(
      notebookId: data.notebookId.present
          ? data.notebookId.value
          : this.notebookId,
      preferences: data.preferences.present
          ? data.preferences.value
          : this.preferences,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UiPreference(')
          ..write('notebookId: $notebookId, ')
          ..write('preferences: $preferences')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(notebookId, preferences);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UiPreference &&
          other.notebookId == this.notebookId &&
          other.preferences == this.preferences);
}

class UiPreferencesCompanion extends UpdateCompanion<UiPreference> {
  final Value<int> notebookId;
  final Value<String?> preferences;
  final Value<int> rowid;
  const UiPreferencesCompanion({
    this.notebookId = const Value.absent(),
    this.preferences = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UiPreferencesCompanion.insert({
    required int notebookId,
    this.preferences = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : notebookId = Value(notebookId);
  static Insertable<UiPreference> custom({
    Expression<int>? notebookId,
    Expression<String>? preferences,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (notebookId != null) 'notebook_id': notebookId,
      if (preferences != null) 'preferences': preferences,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UiPreferencesCompanion copyWith({
    Value<int>? notebookId,
    Value<String?>? preferences,
    Value<int>? rowid,
  }) {
    return UiPreferencesCompanion(
      notebookId: notebookId ?? this.notebookId,
      preferences: preferences ?? this.preferences,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (notebookId.present) {
      map['notebook_id'] = Variable<int>(notebookId.value);
    }
    if (preferences.present) {
      map['preferences'] = Variable<String>(preferences.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UiPreferencesCompanion(')
          ..write('notebookId: $notebookId, ')
          ..write('preferences: $preferences, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NotebooksTable notebooks = $NotebooksTable(this);
  late final $IndexItemsTable indexItems = $IndexItemsTable(this);
  late final $UiPreferencesTable uiPreferences = $UiPreferencesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    notebooks,
    indexItems,
    uiPreferences,
  ];
}

typedef $$NotebooksTableCreateCompanionBuilder =
    NotebooksCompanion Function({
      Value<int> id,
      required String name,
      Value<DateTime> createdAt,
    });
typedef $$NotebooksTableUpdateCompanionBuilder =
    NotebooksCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> createdAt,
    });

final class $$NotebooksTableReferences
    extends BaseReferences<_$AppDatabase, $NotebooksTable, Notebook> {
  $$NotebooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$IndexItemsTable, List<IndexItem>>
  _indexItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.indexItems,
    aliasName: $_aliasNameGenerator(db.notebooks.id, db.indexItems.notebookId),
  );

  $$IndexItemsTableProcessedTableManager get indexItemsRefs {
    final manager = $$IndexItemsTableTableManager(
      $_db,
      $_db.indexItems,
    ).filter((f) => f.notebookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_indexItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UiPreferencesTable, List<UiPreference>>
  _uiPreferencesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.uiPreferences,
    aliasName: $_aliasNameGenerator(
      db.notebooks.id,
      db.uiPreferences.notebookId,
    ),
  );

  $$UiPreferencesTableProcessedTableManager get uiPreferencesRefs {
    final manager = $$UiPreferencesTableTableManager(
      $_db,
      $_db.uiPreferences,
    ).filter((f) => f.notebookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_uiPreferencesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NotebooksTableFilterComposer
    extends Composer<_$AppDatabase, $NotebooksTable> {
  $$NotebooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> indexItemsRefs(
    Expression<bool> Function($$IndexItemsTableFilterComposer f) f,
  ) {
    final $$IndexItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.indexItems,
      getReferencedColumn: (t) => t.notebookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IndexItemsTableFilterComposer(
            $db: $db,
            $table: $db.indexItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> uiPreferencesRefs(
    Expression<bool> Function($$UiPreferencesTableFilterComposer f) f,
  ) {
    final $$UiPreferencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.uiPreferences,
      getReferencedColumn: (t) => t.notebookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UiPreferencesTableFilterComposer(
            $db: $db,
            $table: $db.uiPreferences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotebooksTableOrderingComposer
    extends Composer<_$AppDatabase, $NotebooksTable> {
  $$NotebooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotebooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotebooksTable> {
  $$NotebooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> indexItemsRefs<T extends Object>(
    Expression<T> Function($$IndexItemsTableAnnotationComposer a) f,
  ) {
    final $$IndexItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.indexItems,
      getReferencedColumn: (t) => t.notebookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IndexItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.indexItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> uiPreferencesRefs<T extends Object>(
    Expression<T> Function($$UiPreferencesTableAnnotationComposer a) f,
  ) {
    final $$UiPreferencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.uiPreferences,
      getReferencedColumn: (t) => t.notebookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UiPreferencesTableAnnotationComposer(
            $db: $db,
            $table: $db.uiPreferences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotebooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotebooksTable,
          Notebook,
          $$NotebooksTableFilterComposer,
          $$NotebooksTableOrderingComposer,
          $$NotebooksTableAnnotationComposer,
          $$NotebooksTableCreateCompanionBuilder,
          $$NotebooksTableUpdateCompanionBuilder,
          (Notebook, $$NotebooksTableReferences),
          Notebook,
          PrefetchHooks Function({bool indexItemsRefs, bool uiPreferencesRefs})
        > {
  $$NotebooksTableTableManager(_$AppDatabase db, $NotebooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotebooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotebooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotebooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) =>
                  NotebooksCompanion(id: id, name: name, createdAt: createdAt),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
              }) => NotebooksCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NotebooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({indexItemsRefs = false, uiPreferencesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (indexItemsRefs) db.indexItems,
                    if (uiPreferencesRefs) db.uiPreferences,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (indexItemsRefs)
                        await $_getPrefetchedData<
                          Notebook,
                          $NotebooksTable,
                          IndexItem
                        >(
                          currentTable: table,
                          referencedTable: $$NotebooksTableReferences
                              ._indexItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NotebooksTableReferences(
                                db,
                                table,
                                p0,
                              ).indexItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.notebookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (uiPreferencesRefs)
                        await $_getPrefetchedData<
                          Notebook,
                          $NotebooksTable,
                          UiPreference
                        >(
                          currentTable: table,
                          referencedTable: $$NotebooksTableReferences
                              ._uiPreferencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NotebooksTableReferences(
                                db,
                                table,
                                p0,
                              ).uiPreferencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.notebookId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$NotebooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotebooksTable,
      Notebook,
      $$NotebooksTableFilterComposer,
      $$NotebooksTableOrderingComposer,
      $$NotebooksTableAnnotationComposer,
      $$NotebooksTableCreateCompanionBuilder,
      $$NotebooksTableUpdateCompanionBuilder,
      (Notebook, $$NotebooksTableReferences),
      Notebook,
      PrefetchHooks Function({bool indexItemsRefs, bool uiPreferencesRefs})
    >;
typedef $$IndexItemsTableCreateCompanionBuilder =
    IndexItemsCompanion Function({
      Value<int> id,
      required int notebookId,
      Value<String?> title,
      Value<String?> description,
      required int position,
      Value<String?> extraInfo,
      Value<DateTime> createdAt,
      Value<DateTime> modifiedAt,
    });
typedef $$IndexItemsTableUpdateCompanionBuilder =
    IndexItemsCompanion Function({
      Value<int> id,
      Value<int> notebookId,
      Value<String?> title,
      Value<String?> description,
      Value<int> position,
      Value<String?> extraInfo,
      Value<DateTime> createdAt,
      Value<DateTime> modifiedAt,
    });

final class $$IndexItemsTableReferences
    extends BaseReferences<_$AppDatabase, $IndexItemsTable, IndexItem> {
  $$IndexItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NotebooksTable _notebookIdTable(_$AppDatabase db) =>
      db.notebooks.createAlias(
        $_aliasNameGenerator(db.indexItems.notebookId, db.notebooks.id),
      );

  $$NotebooksTableProcessedTableManager get notebookId {
    final $_column = $_itemColumn<int>('notebook_id')!;

    final manager = $$NotebooksTableTableManager(
      $_db,
      $_db.notebooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_notebookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IndexItemsTableFilterComposer
    extends Composer<_$AppDatabase, $IndexItemsTable> {
  $$IndexItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extraInfo => $composableBuilder(
    column: $table.extraInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$NotebooksTableFilterComposer get notebookId {
    final $$NotebooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.notebookId,
      referencedTable: $db.notebooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotebooksTableFilterComposer(
            $db: $db,
            $table: $db.notebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IndexItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $IndexItemsTable> {
  $$IndexItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extraInfo => $composableBuilder(
    column: $table.extraInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$NotebooksTableOrderingComposer get notebookId {
    final $$NotebooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.notebookId,
      referencedTable: $db.notebooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotebooksTableOrderingComposer(
            $db: $db,
            $table: $db.notebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IndexItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IndexItemsTable> {
  $$IndexItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get extraInfo =>
      $composableBuilder(column: $table.extraInfo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => column,
  );

  $$NotebooksTableAnnotationComposer get notebookId {
    final $$NotebooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.notebookId,
      referencedTable: $db.notebooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotebooksTableAnnotationComposer(
            $db: $db,
            $table: $db.notebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IndexItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IndexItemsTable,
          IndexItem,
          $$IndexItemsTableFilterComposer,
          $$IndexItemsTableOrderingComposer,
          $$IndexItemsTableAnnotationComposer,
          $$IndexItemsTableCreateCompanionBuilder,
          $$IndexItemsTableUpdateCompanionBuilder,
          (IndexItem, $$IndexItemsTableReferences),
          IndexItem,
          PrefetchHooks Function({bool notebookId})
        > {
  $$IndexItemsTableTableManager(_$AppDatabase db, $IndexItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IndexItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IndexItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IndexItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> notebookId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String?> extraInfo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> modifiedAt = const Value.absent(),
              }) => IndexItemsCompanion(
                id: id,
                notebookId: notebookId,
                title: title,
                description: description,
                position: position,
                extraInfo: extraInfo,
                createdAt: createdAt,
                modifiedAt: modifiedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int notebookId,
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required int position,
                Value<String?> extraInfo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> modifiedAt = const Value.absent(),
              }) => IndexItemsCompanion.insert(
                id: id,
                notebookId: notebookId,
                title: title,
                description: description,
                position: position,
                extraInfo: extraInfo,
                createdAt: createdAt,
                modifiedAt: modifiedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IndexItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({notebookId = false}) {
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
                    if (notebookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.notebookId,
                                referencedTable: $$IndexItemsTableReferences
                                    ._notebookIdTable(db),
                                referencedColumn: $$IndexItemsTableReferences
                                    ._notebookIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$IndexItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IndexItemsTable,
      IndexItem,
      $$IndexItemsTableFilterComposer,
      $$IndexItemsTableOrderingComposer,
      $$IndexItemsTableAnnotationComposer,
      $$IndexItemsTableCreateCompanionBuilder,
      $$IndexItemsTableUpdateCompanionBuilder,
      (IndexItem, $$IndexItemsTableReferences),
      IndexItem,
      PrefetchHooks Function({bool notebookId})
    >;
typedef $$UiPreferencesTableCreateCompanionBuilder =
    UiPreferencesCompanion Function({
      required int notebookId,
      Value<String?> preferences,
      Value<int> rowid,
    });
typedef $$UiPreferencesTableUpdateCompanionBuilder =
    UiPreferencesCompanion Function({
      Value<int> notebookId,
      Value<String?> preferences,
      Value<int> rowid,
    });

final class $$UiPreferencesTableReferences
    extends BaseReferences<_$AppDatabase, $UiPreferencesTable, UiPreference> {
  $$UiPreferencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NotebooksTable _notebookIdTable(_$AppDatabase db) =>
      db.notebooks.createAlias(
        $_aliasNameGenerator(db.uiPreferences.notebookId, db.notebooks.id),
      );

  $$NotebooksTableProcessedTableManager get notebookId {
    final $_column = $_itemColumn<int>('notebook_id')!;

    final manager = $$NotebooksTableTableManager(
      $_db,
      $_db.notebooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_notebookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UiPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $UiPreferencesTable> {
  $$UiPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get preferences => $composableBuilder(
    column: $table.preferences,
    builder: (column) => ColumnFilters(column),
  );

  $$NotebooksTableFilterComposer get notebookId {
    final $$NotebooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.notebookId,
      referencedTable: $db.notebooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotebooksTableFilterComposer(
            $db: $db,
            $table: $db.notebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UiPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $UiPreferencesTable> {
  $$UiPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get preferences => $composableBuilder(
    column: $table.preferences,
    builder: (column) => ColumnOrderings(column),
  );

  $$NotebooksTableOrderingComposer get notebookId {
    final $$NotebooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.notebookId,
      referencedTable: $db.notebooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotebooksTableOrderingComposer(
            $db: $db,
            $table: $db.notebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UiPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UiPreferencesTable> {
  $$UiPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get preferences => $composableBuilder(
    column: $table.preferences,
    builder: (column) => column,
  );

  $$NotebooksTableAnnotationComposer get notebookId {
    final $$NotebooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.notebookId,
      referencedTable: $db.notebooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotebooksTableAnnotationComposer(
            $db: $db,
            $table: $db.notebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UiPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UiPreferencesTable,
          UiPreference,
          $$UiPreferencesTableFilterComposer,
          $$UiPreferencesTableOrderingComposer,
          $$UiPreferencesTableAnnotationComposer,
          $$UiPreferencesTableCreateCompanionBuilder,
          $$UiPreferencesTableUpdateCompanionBuilder,
          (UiPreference, $$UiPreferencesTableReferences),
          UiPreference,
          PrefetchHooks Function({bool notebookId})
        > {
  $$UiPreferencesTableTableManager(_$AppDatabase db, $UiPreferencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UiPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UiPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UiPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> notebookId = const Value.absent(),
                Value<String?> preferences = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UiPreferencesCompanion(
                notebookId: notebookId,
                preferences: preferences,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int notebookId,
                Value<String?> preferences = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UiPreferencesCompanion.insert(
                notebookId: notebookId,
                preferences: preferences,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UiPreferencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({notebookId = false}) {
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
                    if (notebookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.notebookId,
                                referencedTable: $$UiPreferencesTableReferences
                                    ._notebookIdTable(db),
                                referencedColumn: $$UiPreferencesTableReferences
                                    ._notebookIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$UiPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UiPreferencesTable,
      UiPreference,
      $$UiPreferencesTableFilterComposer,
      $$UiPreferencesTableOrderingComposer,
      $$UiPreferencesTableAnnotationComposer,
      $$UiPreferencesTableCreateCompanionBuilder,
      $$UiPreferencesTableUpdateCompanionBuilder,
      (UiPreference, $$UiPreferencesTableReferences),
      UiPreference,
      PrefetchHooks Function({bool notebookId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NotebooksTableTableManager get notebooks =>
      $$NotebooksTableTableManager(_db, _db.notebooks);
  $$IndexItemsTableTableManager get indexItems =>
      $$IndexItemsTableTableManager(_db, _db.indexItems);
  $$UiPreferencesTableTableManager get uiPreferences =>
      $$UiPreferencesTableTableManager(_db, _db.uiPreferences);
}
