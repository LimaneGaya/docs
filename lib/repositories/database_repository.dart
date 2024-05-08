import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:docs/app/constants.dart';
import 'package:docs/app/providers.dart';
import 'package:docs/app/utils.dart';
import 'package:docs/models/models.dart';
import 'package:docs/repositories/repository_exception.dart';

final _databaseRepositoryProvider = Provider<DatabaseRepository>((ref) {
  return DatabaseRepository(ref);
});

class DatabaseRepository with RepositoryExceptionMixin {
  DatabaseRepository(this._read);

  final Ref _read;

  static Provider<DatabaseRepository> get provider =>
      _databaseRepositoryProvider;

  Realtime get _realtime => _read.read(Dependency.realtime);

  Databases get _database => _read.read(Dependency.database);

  Future<void> createNewPage({
    required String documentId,
    required String owner,
  }) async {
    return exceptionHandler(
        _createPageAndDelta(owner: owner, documentId: documentId));
  }

  Future<void> _createPageAndDelta({
    required String documentId,
    required String owner,
  }) async {
    Future.wait([
      _database.createDocument(
        databaseId: databaseId,
        collectionId: CollectionNames.pages,
        documentId: documentId,
        data: {
          'owner': owner,
          'title': null,
          'content': null,
        },
      ),
      _database.createDocument(
        databaseId: databaseId,
        collectionId: CollectionNames.delta,
        documentId: documentId,
        data: {
          'delta': null,
          'user': null,
          'deviceId': null,
        },
      ),
    ]);
  }

  Future<DocumentPageData> getPage({
    required String documentId,
  }) {
    return exceptionHandler(_getPage(documentId));
  }

  Future<DocumentPageData> _getPage(String documentId) async {
    final doc = await _database.getDocument(
      databaseId: databaseId,
      collectionId: CollectionNames.pages,
      documentId: documentId,
    );
    return DocumentPageData.fromMap(doc.data);
  }

  Future<List<DocumentPageData>> getAllPages(String userId) async {
    return exceptionHandler(_getAllPages(userId));
  }

  Future<List<DocumentPageData>> _getAllPages(String userId) async {
    final result = await _database.listDocuments(
      databaseId: databaseId,
      collectionId: CollectionNames.pages,
      queries: [Query.equal('owner', userId)],
    );
    return result.documents.map((element) {
      return DocumentPageData.fromMap(element.data);
    }).toList();
  }

  Future<void> updatePage(
      {required String documentId,
      required DocumentPageData documentPage}) async {
    return exceptionHandler(
      _database.updateDocument(
        databaseId: databaseId,
        collectionId: CollectionNames.pages,
        documentId: documentId,
        data: documentPage.toMap(),
      ),
    );
  }

  Future<void> updateDelta({
    required String pageId,
    required DeltaData deltaData,
  }) {
    return exceptionHandler(
      _database.updateDocument(
        databaseId: databaseId,
        collectionId: CollectionNames.delta,
        documentId: pageId,
        data: deltaData.toMap(),
      ),
    );
  }

  RealtimeSubscription subscribeToPage({required String pageId}) {
    try {
      return _realtime
          .subscribe(['${CollectionNames.deltaDocumentsPath}.$pageId']);
    } on AppwriteException catch (e) {
      logger.warning(e.message, e);
      throw RepositoryException(
          message: e.message ?? 'An undefined error occured');
    } on Exception catch (e, st) {
      logger.severe('Error subscribing to page changes', e, st);
      throw RepositoryException(
          message: 'Error subscribing to page changes',
          exception: e,
          stackTrace: st);
    }
  }
}
