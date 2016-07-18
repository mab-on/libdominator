#libdominator
libdominator is a HTML parser library written in [d](http://www.dlang.org) 

#example
```dlang
const string content = `<div id="div-2-div-1">
        <ol id="ol-1">
          <li id="li-1-ol-1">li-1-ol-1 Inner</li>
          <li id="li-2-ol-1">li-2-ol-1 Inner</li>
          <li id="li-3-ol-1">li-3-ol-1 Inner</li>
        </ol>
      </div>`;
      Dominator dom = new Dominator(content);
      assert( dom.getNodes.length == 5);
      assert( dom.filterDom(DomFilter("ol")).length == 1 );
      assert( dom.filterDom(DomFilter("ol.li")).length == 3 );
      assert( dom.filterDom(DomFilter("ol.li{id:li-3-ol-1}")).length == 1 );
```
 ```dlang
 Dominator dom = new Dominator(readText("dummy.html"));
    auto filter = DomFilter("article");
    assert( dom.filterDom(filter).filterComments().length == 1 );
    assert( dom.filterDom(filter).length == 3 );

    filter = DomFilter("div.*.ol.li");
    assert( dom.filterDom(filter).length == 3 );

    filter = DomFilter("div.ol.li");
    assert( dom.filterDom(filter).length == 6 );

    filter = DomFilter("ol.li");
    assert( dom.filterDom(filter).length == 6 );

    filter = DomFilter(`ol.li{id:(regex)^li-[\d]+}`);
    assert( dom.filterDom(filter).length == 6 );

    filter = DomFilter(`ol{id:ol-1}.li{id:(regex)^li-[\d]+}`);
    assert( dom.filterDom(filter).length == 3 );
  ```

Or check out https://github.com/mab-on/dominator