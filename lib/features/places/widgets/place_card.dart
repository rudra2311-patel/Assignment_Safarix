import 'package:flutter/material.dart';
import '../../../models/place_model.dart';
import '../../../core/constants/app_constants.dart';

/// Reusable place card widget
/// Displays a single place in the list
class PlaceCard extends StatelessWidget {
  final Place place;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onCheckboxChanged;

  const PlaceCard({
    super.key,
    required this.place,
    required this.isSelected,
    required this.onTap,
    required this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) => onCheckboxChanged(),
                activeColor: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              _buildPlaceIcon(context),
              const SizedBox(width: 12),
              Expanded(child: _buildPlaceInfo()),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceIcon(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.place, color: Theme.of(context).primaryColor),
    );
  }

  Widget _buildPlaceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          place.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '${place.dist.toStringAsFixed(0)}m away',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        if (place.kinds.isNotEmpty)
          Text(
            place.kinds.split(',').take(2).join(', '),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}
