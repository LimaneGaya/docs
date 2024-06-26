import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:docs/app/navigation/routes.dart';
import 'package:docs/app/providers.dart';
import 'package:docs/repositories/repository_exception.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

class NewDocumentPage extends ConsumerStatefulWidget {
  const NewDocumentPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NewDocumentPageState();
}

class _NewDocumentPageState extends ConsumerState<NewDocumentPage> {
  final _uuid = const Uuid();

  bool showError = false;

  @override
  void initState() {
    super.initState();
    _createNewPage();
  }

  Future<void> _createNewPage() async {
    final documentId = _uuid.v4();
    try {
      await ref.read(Repository.database).createNewPage(
            documentId: documentId,
            owner: ref.read(AppState.auth).user!.$id,
          );
      if (mounted) {
        Routemaster.of(context).push('${AppRoutes.document}/$documentId');
      }
    } on RepositoryException catch (_) {
      setState(() {
        showError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showError) {
      return const Center(
        child: Text('An error occured'),
      );
    } else {
      return const SizedBox();
    }
  }
}
