// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

  function setupTablesorter() {
    console.log("starting")
    $(".tablesorter").each(function (i, e) {
      var myHeaders = {}
      $(this).find('th.nosort').each(function (i, e) {
        myHeaders[$(this).index()] = {sorter : false };
      });
      console.log("myheaders is "+myHeaders)
      $(this).tablesorter({widgets: ['zebra'], headers: myHeaders });
    });
  }
