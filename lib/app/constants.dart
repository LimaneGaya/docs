const appwriteEndpoint = 'https://cloud.appwrite.io/v1';
const appwriteProjectId = '663b98fd0000c6d5840c'; // TODO: modify this
const databaseId = '663b9b88001d89726204';
const collectionId = '663b9ba400009c0f76ed';

abstract class CollectionNames {
  static String get delta => '663b9ba400009c0f76ed';
  static String get deltaDocumentsPath => 'collections.$delta.documents';
  static String get pages => '663b9cbb000098dcb908';
  static String get pagesDocumentsPath => 'collections.$pages.documents';
}
