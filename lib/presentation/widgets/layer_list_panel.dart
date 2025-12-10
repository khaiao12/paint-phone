import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/layer_provider.dart';

class LayerListPanel extends StatelessWidget {
  final VoidCallback? onClose;

  const LayerListPanel({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [

              //           HEADER

              Row(
                children: [
                  Text(
                    "Layers",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const Spacer(),

                  // ADD LAYER
                  _headerIcon(
                    icon: Icons.add,
                    color: Colors.green,
                    onTap: () => context.read<LayerProvider>().addLayer(),
                  ),

                  const SizedBox(width: 6),

                  // CLOSE
                  _headerIcon(
                    icon: Icons.close,
                    color: Colors.redAccent,
                    onTap: onClose ?? () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              //        LIST OF LAYERS

              Expanded(
                child: Consumer<LayerProvider>(
                  builder: (context, provider, _) {
                    return ListView.builder(
                      controller: controller,
                      itemCount: provider.layers.length,
                      itemBuilder: (context, index) {
                        final layer = provider.layers[index];
                        final isSelected =
                            index == provider.currentLayerIndex;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.shade50
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                            border: isSelected
                                ? Border.all(color: Colors.blue, width: 2)
                                : null,
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.20),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                            ],
                          ),

                          child: Row(
                            children: [
                              // VISIBILITY TOGGLE
                              IconButton(
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

                              const SizedBox(width: 4),

                              // NAME (TAP TO SELECT)
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => provider.selectLayer(index),
                                  child: Text(
                                    layer.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.blue.shade800
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),

                              // RENAME BUTTON
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                color: Colors.blue.shade600,
                                onPressed: () =>
                                    _renameLayer(context, provider, index),
                              ),

                              // DELETE LAYER (if >1)
                              if (provider.layers.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  color: Colors.red.shade400,
                                  onPressed: () =>
                                      provider.removeLayer(index),
                                ),
                            ],
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

  //   HEADER ICON BUTTON

  Widget _headerIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: color),
      ),
    );
  }

  //        RENAME LAYER

  void _renameLayer(
      BuildContext context, LayerProvider provider, int index) {
    final controller = TextEditingController(
      text: provider.layers[index].name,
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Đổi tên layer"),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
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
