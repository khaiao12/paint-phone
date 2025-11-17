import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/layer_provider.dart';

class LayerListPanel extends StatelessWidget {
  final VoidCallback onClose;

  const LayerListPanel({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, -2),
            color: Colors.black26,
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Consumer<LayerProvider>(
        builder: (context, layerProv, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Danh sách Layer",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  )
                ],
              ),

              const SizedBox(height: 12),

              // --- Danh sách layer ---
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: ListView.builder(
                  itemCount: layerProv.layers.length,
                  itemBuilder: (context, index) {
                    final isSelected =
                        index == layerProv.currentLayerIndex;

                    return Card(
                      color:
                      isSelected ? Colors.blue.shade50 : Colors.white,
                      child: ListTile(
                        title: Text("Layer ${index + 1}"),
                        onTap: () => layerProv.selectLayer(index),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => layerProv.removeLayer(index),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // --- Add Layer Button ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => layerProv.addLayer(),
                  icon: const Icon(Icons.add),
                  label: const Text("Thêm layer mới"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
