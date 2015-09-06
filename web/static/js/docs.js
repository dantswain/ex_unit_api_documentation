class Docs {
  static init() {
    $.getJSON("/docs/index.json", function(data) {
      console.log(data);
      $(data).each(function(ix, datum) {
        console.log(datum);
        $.getJSON(datum, function(datii) {
          console.log(datii);
          $('div#docs').append(JSON.stringify(datii));
        });
      });
    });
  }
}

$( () => Docs.init() );

export default Docs
