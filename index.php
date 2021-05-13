<?php
/*
* This function changes the single byte "unit" returned by DH command in shell,
* and returns a two byte representation of it.
*
* @param: $string - the single byte string
* @return: Two byte representation of $string
*/
function convertFileBytes($string)
{
  // Remove the last character from $string
  $value = trim(substr($string, 0, -1));

  switch (trim(substr($string, -1))) {
    case 'T':
    return $value . " TB";
    case 'G':
    return $value . " GB";
    case 'M':
    return $value . " MB";
    case 'K':
    return $value . " KB";

    default:
    return $value;
  }
}
/*
* Get the content of the $path and sort the result alphabetically, returning the
* directories first.
*
* @param: $path
* @return: Sorted $content; directories before files
*/
function getDirContent($path)
{
  $content = glob($path . '*');
  // Sort results alphabetically and return directories first
  usort($content, function ($a, $b) {
    $aIsDir = is_dir($a);
    $bIsDir = is_dir($b);
    if ($aIsDir === $bIsDir)
    return strnatcasecmp($a, $b); // both are dirs or files
    elseif ($aIsDir && !$bIsDir)
    return -1; // if $a is dir - it should be before $b
    elseif (!$aIsDir && $bIsDir)
    return 1; // $b is dir, should be before $a
  });

  return $content;
}

// Convert filesize() results into 2 decimal points output
function human_filesize($bytes, $decimals = 2) {
  $sz = 'BKMGTP';
  $factor = floor((strlen($bytes) - 1) / 3);
  return sprintf("%.{$decimals}f", $bytes / pow(1024, $factor)) . @$sz[$factor];
}

// Get drive info
$diskInfoCommand = shell_exec("df -h /media/hdd");
$diskInfoResult = array_filter(explode(" ", $diskInfoCommand), function($value) { return $value !== ''; });
$diskInfo = array();

foreach ($diskInfoResult as $value) { array_push($diskInfo, $value); }

$path = (isset($_GET['folder'])) ? "$_GET[folder]/" : "/media/hdd/videos/";

?>
<!DOCTYPE html>
<html lang="en" dir="ltr">
<head>
  <meta charset="utf-8">
  <title>Super Amazing Page</title>
  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
  <style media="screen">
  @media screen and (min-width: 1280px) {
    .table {
      margin: auto;
      width: 50% !important;
    }
  }
  </style>
</head>
<body class="text-center">
  <div class="container-fluid">
  <h1>Disk Info</h1>
  <table class="table table-bordered">
    <thead class="table-dark">
      <tr>
        <th>Navigation</th>
        <th>Total Space</th>
        <th>Space Used</th>
        <th>Available</th>
      </tr>
    </thead>
    <tr>
      <td><a class="btn btn-primary" href="/">Home</a></td>
      <td><?php echo convertFileBytes($diskInfo[7]); ?></td>
      <td><?php echo convertFileBytes($diskInfo[8]) . " (" . $diskInfo[10] . ")"; ?></td>
      <td><?php echo convertFileBytes($diskInfo[9]) . " (" . (100 - substr($diskInfo[10], 0, 2)) . "%)"; ?></td>
    </tr>
  </table>
  <h1>Files Info</h1>
  <table class="table table-bordered">
    <thead class="table-dark">
      <tr>
        <th>Select</th>
        <th>Name</th>
        <th>Size</th>
      </tr>
    </thead>
    <form action="#" method="post">
      <p><input type="submit" class="btn btn-danger" name="submit" value="Delete Selected Files"></p>
      <?php
      // Checkbox processing to delete selected files
      if($_SERVER['REQUEST_METHOD'] == 'POST')
      {
        if(isset($_POST['submit']) && !empty($_POST['check_list']))
        {
          foreach ($_POST['check_list'] as $value) {
            shell_exec("sudo rm -rf $path'$value'");
          }
        } else {
          echo "Please select a file or folder";
        }
      }

      $path .= "//";
      foreach (getDirContent($path) as $content)
      {
        $contentName = explode("///", $content);

        echo "<tr><td><input class='form-check-input' type='checkbox' name='check_list[]' value='$contentName[1]'></td>";

        if(is_dir($content))
        {
          echo "<td><a href='?folder=$contentName[0]/$contentName[1]'>$contentName[1]</a></td>";
          echo "<td>Directory</td></tr>";
        } else {
          echo "<td>$contentName[1]</td>";
          echo "<td>" . human_filesize(filesize($content)) . "</td></tr>";
        }
      }
      ?>
    </form>
  </table>
  </div>
</body>
</html>
