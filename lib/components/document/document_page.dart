import 'dart:convert';

import 'package:flutter/material.dart' hide MenuBar;
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:docs/app/app.dart';
import 'package:docs/app/navigation/routes.dart';
import 'package:docs/app/providers.dart';
import 'package:docs/components/document/state/document_controller.dart';
import 'package:docs/components/document/widgets/widgets.dart';

final _quillControllerProvider =
    Provider.family<QuillController?, String>((ref, id) {
  final test = ref.watch(DocumentController.provider(id));
  return test.quillController;
});

class DocumentPage extends ConsumerWidget {
  const DocumentPage({
    super.key,
    required this.documentId,
  });

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          MenuBar(
            leading: [_TitleTextEditor(documentId: documentId)],
            trailing: [_IsSavedWidget(documentId: documentId)],
            newDocumentPressed: () {
              Routemaster.of(context).push(AppRoutes.newDocument);
            },
            signOutPressed: () {
              ref.read(AppState.auth.notifier).signOut();
            },
            openDocumentsPressed: () {
              Future.delayed(const Duration(seconds: 0), () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints.loose(const Size(1400, 700)),
                          child: const AllDocumentsPopup(),
                        ),
                      );
                    });
              });
            },
          ),
          _Toolbar(documentId: documentId),
          Expanded(
            child: _DocumentEditorWidget(
              documentId: documentId,
            ),
          ),
        ],
      ),
    );
  }
}

final _documentTitleProvider = Provider.family<String?, String>((ref, id) {
  return ref.watch(DocumentController.provider(id)).documentPageData?.title;
});

class _TitleTextEditor extends ConsumerStatefulWidget {
  const _TitleTextEditor({
    required this.documentId,
  });
  final String documentId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      __TitleTextEditorState();

  _TitleTextEditor copyWith({
    String? documentId,
  }) {
    return _TitleTextEditor(
      documentId: documentId ?? this.documentId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
    };
  }

  factory _TitleTextEditor.fromMap(Map<String, dynamic> map) {
    return _TitleTextEditor(
      documentId: map['documentId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory _TitleTextEditor.fromJson(String source) =>
      _TitleTextEditor.fromMap(json.decode(source));
}

class __TitleTextEditorState extends ConsumerState<_TitleTextEditor> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(
      _documentTitleProvider(widget.documentId),
      (String? previousValue, String? newValue) {
        if (newValue != _textEditingController.text) {
          _textEditingController.text = newValue ?? '';
        }
      },
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IntrinsicWidth(
        child: TextField(
          controller: _textEditingController,
          onChanged:
              ref.read(DocumentController.notifier(widget.documentId)).setTitle,
          decoration: const InputDecoration(
            hintText: 'Untitled document',
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent, width: 3),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 3),
            ),
          ),
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}

final _isSavedRemotelyProvider = Provider.family<bool, String>((ref, id) {
  return ref.watch(DocumentController.provider(id)).isSavedRemotely;
});

class _IsSavedWidget extends ConsumerWidget {
  const _IsSavedWidget({required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isSaved = ref.watch(_isSavedRemotelyProvider(documentId));
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Saved',
        style: TextStyle(
          fontSize: 18,
          color: isSaved ? AppColors.secondary : Colors.grey,
        ),
      ),
    );
  }
}

class _DocumentEditorWidget extends ConsumerStatefulWidget {
  const _DocumentEditorWidget({
    required this.documentId,
  });

  final String documentId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      __DocumentEditorState();
}

class __DocumentEditorState extends ConsumerState<_DocumentEditorWidget> {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final quillController =
        ref.watch(_quillControllerProvider(widget.documentId));

    if (quillController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (HardwareKeyboard.instance.isControlPressed &&
                  event.character == 'b' ||
              HardwareKeyboard.instance.isMetaPressed &&
                  event.character == 'b') {
            if (quillController
                .getSelectionStyle()
                .attributes
                .keys
                .contains('bold')) {
              quillController
                  .formatSelection(Attribute.clone(Attribute.bold, null));
            } else {
              quillController.formatSelection(Attribute.bold);
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Card(
            elevation: 7,
            child: Padding(
              padding: const EdgeInsets.all(86.0),
              child: QuillEditor.basic(
                configurations: QuillEditorConfigurations(
                  controller: quillController,
                  scrollable: true,
                  autoFocus: false,
                  expands: false,
                  padding: EdgeInsets.zero,
                  customStyles: DefaultStyles(
                    h1: const DefaultTextBlockStyle(
                      TextStyle(
                        fontSize: 36,
                        color: Colors.black,
                        height: 1.15,
                        fontWeight: FontWeight.w600,
                      ),
                      VerticalSpacing(32, 28),
                      VerticalSpacing(0, 0),
                      null,
                    ),
                    h2: const DefaultTextBlockStyle(
                      TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      VerticalSpacing(28, 24),
                      VerticalSpacing(0, 0),
                      null,
                    ),
                    h3: DefaultTextBlockStyle(
                      TextStyle(
                        fontSize: 24,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w600,
                      ),
                      const VerticalSpacing(18, 14),
                      const VerticalSpacing(0, 0),
                      null,
                    ),
                    paragraph: const DefaultTextBlockStyle(
                      TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                      VerticalSpacing(2, 0),
                      VerticalSpacing(0, 0),
                      null,
                    ),
                  ),
                ),
                scrollController: _scrollController,
                focusNode: _focusNode,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _defaultEmbedBuilderWeb(BuildContext context, QuillRawEditor node) {
    throw UnimplementedError(
      'Embeddable type "${node.runtimeType}" is not supported by default '
      'embed builder of QuillEditor. You must pass your own builder function '
      'to embedBuilder property of QuillEditor or QuillField widgets.',
    );
  }
}

class _Toolbar extends ConsumerWidget {
  const _Toolbar({
    required this.documentId,
  });

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quillController = ref.watch(_quillControllerProvider(documentId));

    if (quillController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return QuillToolbar.simple(
      configurations: QuillSimpleToolbarConfigurations(
        controller: quillController,
        multiRowsDisplay: false,
        showAlignmentButtons: true,
      ),
    );
  }
}
