import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/layer_provider.dart';

class LayerListPanel extends StatelessWidget {
  final VoidCallback? onClose;

  const LayerListPanel({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(12),

          child: Column(
            children: [
              /// HEADER
              Row(
                children: [
                  const Text(
                    "Layers",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),

                  /// ADD LAYER
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => context.read<LayerProvider>().addLayer(),
                  ),

                  /// CLOSE PANEL
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose ?? () => Navigator.pop(context),
                  )
                ],
              ),

              const SizedBox(height: 8),

              /// LIST OF LAYERS
              Expanded(
                child: Consumer<LayerProvider>(
                  builder: (context, provider, _) {
                    return ListView.builder(
                      controller: controller,
                      itemCount: provider.layers.length,
                      itemBuilder: (context, index) {
                        final layer = provider.layers[index];
                        final isSelected = index == provider.currentLayerIndex;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            dense: true,

                            /// TOGGLE VISIBILITY
                            leading: IconButton(
                              icon: Icon(
                                layer.visible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: layer.visible
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              onPressed: () =>
                                  provider.toggleLayerVisibility(index),
                            ),

                            /// NAME
                            title: Text(
                              layer.name,
                              style: TextStyle(
                                fontWeight:
                                isSelected ? FontWeight.bold : null,
                              ),
                            ),

                            /// SELECT LAYER
                            onTap: () => provider.selectLayer(index),

                            /// EDIT + DELETE BUTTONS
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /// RENAME
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () =>
                                      _renameLayer(context, provider, index),
                                ),

                                /// DELETE
                                if (provider.layers.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () =>
                                        provider.removeLayer(index),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// RENAME LAYER FUNCTION
  void _renameLayer(
      BuildContext context, LayerProvider provider, int index) {

    final controller = TextEditingController(
      text: provider.layers[index].name,
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Đổi tên layer"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Tên layer mới...",
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Hủy"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Lưu"),
            onPressed: () {
              provider.renameLayer(index, controller.text.trim());
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
