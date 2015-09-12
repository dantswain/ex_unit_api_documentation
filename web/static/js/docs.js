class Docs {
  static formatRequest(request) {
    var verb = request.request_method;
    var urlParser = document.createElement('a');
    urlParser.href = request.request_path;

    var path = urlParser.pathname;
    var requestBody = request.request_body;
    var responseBody = request.response_body;
    var statusCode = request.status_code;

    var str = '<span class="doc-request-request">';
    str += verb.toUpperCase() + ' ' + path + '</span>';
    str += '<dl>';
    str += '<dt>Request body</dt>';
    str += '<dd>' + requestBody + '</dd>';
    str += '<dt>Response status</dt>';
    str += '<dd>' + statusCode + '</dd>';
    str += '<dt>Response Body</dt>';
    str += '<dd>' + responseBody + '</dd>';
    str += '</dl>';
    return str;
  }

  static formatCase(doc) {
    var verb = doc.http_method;
    var urlParser = document.createElement('a');
    urlParser.href = doc.route;

    var path = urlParser.pathname;

    var str = '<span class="doc-request">';
    str += verb.toUpperCase() + ' ' + path;
    str += '</span><br/>';
    str += 'Requests:';
    str += '<ul>';
    $(doc.requests).each(function(ix, request) {
      str += '<li>' + Docs.formatRequest(request) + '</li>';
    });
    str += '</ul>';
    return str;
  }

  static displayDoc(docs) {
    $('#docs-title').html(docs.name);
    $(docs.docs).each(function(ix, doc_case) {
      var as_str = '<li>' + Docs.formatCase(doc_case) + '</li>';
      $('#docs-list').append(as_str);
    });
  }

  static init() {
    $.getJSON("/docs/index.json", function(data) {
      $(data).each(function(ix, doc) {
        $.getJSON(doc, function(docs) {
          Docs.displayDoc(docs);
        });
      });
    });
  }
}

$( () => Docs.init() );

export default Docs
