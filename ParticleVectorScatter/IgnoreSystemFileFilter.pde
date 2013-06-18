import java.io.File;
import java.io.FileFilter;

public class IgnoreSystemFileFilter implements FileFilter {
  public boolean accept(File _file) {
    if (_file.getName().startsWith(".") && _file.isHidden()) {
      return false;
    }
    return true;
  }
}
