import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/draft_listing_model.dart';
import '../services/local_db_service.dart';
import '../theme/app_theme.dart';

// Banner draft yang tersimpan di HP (Hive). Hilang sendiri saat box kosong.
class PengingatDraftLokal extends StatelessWidget {
  final VoidCallback onTap;

  const PengingatDraftLokal({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<DraftListingModel>>(
      valueListenable: LocalDbService.pantauDraft(),
      builder: (context, Box<DraftListingModel> box, child) {
        if (box.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.jarakTepi,
            AppTheme.jarakKecil,
            AppTheme.jarakTepi,
            0,
          ),
          child: Material(
            color: AppTheme.warnaLatarPeringatan,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radius),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.jarakSedang),
                child: Row(
                  children: [
                    const Icon(
                      Icons.edit_note,
                      color: AppTheme.warnaTeksPeringatan,
                    ),
                    const SizedBox(width: AppTheme.jarakKecil),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${box.length} draft tersimpan di HP',
                            style: const TextStyle(
                              fontSize: AppTheme.fontNormal,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.warnaTeksPeringatan,
                            ),
                          ),
                          const Text(
                            'Belum diterbitkan ke katalog',
                            style: TextStyle(
                              fontSize: AppTheme.fontLabel,
                              color: AppTheme.warnaTeksPeringatan,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Lanjutkan',
                      style: TextStyle(
                        fontSize: AppTheme.fontNormal,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.warnaTeksPeringatan,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
