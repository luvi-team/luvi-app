import 'main_dev.dart' as dev;
import 'main_prod.dart' as prod;

void main(List<String> args) {
  const env = String.fromEnvironment('APP_ENV', defaultValue: 'prod');
  if (env == 'dev') {
    dev.main();
  } else {
    prod.main();
  }
}
