import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/template.dart';
import '../../../data/repositories/template_repository.dart';

final templatesProvider = FutureProvider<List<Template>>((ref) {
  return TemplateRepository.getAll();
});
