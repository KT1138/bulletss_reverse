#ifndef BULLETML_H
#define BULLETML_H

class BulletMLParserTinyXML;
class BulletMLParser;
class BulletMLState;
class BulletMLRunner;


extern "C" {
  BulletMLParserTinyXML* BulletMLParserTinyXML_new(char*);
  void BulletMLParserTinyXML_parse(BulletMLParserTinyXML* );
  void BulletMLParserTinyXML_delete(BulletMLParserTinyXML*);
  BulletMLRunner* BulletMLRunner_new_parser(BulletMLParser*);
  BulletMLRunner* BulletMLRunner_new_state(BulletMLState*);
  void BulletMLRunner_delete(BulletMLRunner*);
  void BulletMLRunner_run(BulletMLRunner* );
  bool BulletMLRunner_isEnd(BulletMLRunner* );
  void BulletMLRunner_delete(BulletMLRunner*);
  void BulletMLRunner_run(BulletMLRunner* );
  bool BulletMLRunner_isEnd(BulletMLRunner* );
  void BulletMLRunner_set_getBulletDirection(BulletMLRunner*, double (*fp) (BulletMLRunner* )); 
  void BulletMLRunner_set_getAimDirection(BulletMLRunner*, double (*fp) (BulletMLRunner* )); 
  void BulletMLRunner_set_getBulletSpeed(BulletMLRunner*, double (*fp) (BulletMLRunner* )); 
  void BulletMLRunner_set_getDefaultSpeed(BulletMLRunner*, double (*fp) (BulletMLRunner* )); 
  void BulletMLRunner_set_getRank(BulletMLRunner*, double (*fp) (BulletMLRunner* )); 
  void BulletMLRunner_set_createSimpleBullet(BulletMLRunner*, void (*fp) (BulletMLRunner* , double, double)); 
  void BulletMLRunner_set_createBullet(BulletMLRunner*, void (*fp) (BulletMLRunner* , BulletMLState*, double, double)); 
  void BulletMLRunner_set_getTurn(BulletMLRunner*, int (*fp) (BulletMLRunner* )); 
  void BulletMLRunner_set_doVanish(BulletMLRunner*, void (*fp) (BulletMLRunner* )); 
  void BulletMLRunner_set_doChangeDirection(BulletMLRunner*, void (*fp) (BulletMLRunner* , double)); 
  void BulletMLRunner_set_doChangeSpeed(BulletMLRunner*, void (*fp) (BulletMLRunner* , double)); 
  void BulletMLRunner_set_doAccelX(BulletMLRunner*, void (*fp) (BulletMLRunner* , double)); 
  void BulletMLRunner_set_doAccelY(BulletMLRunner*, void (*fp) (BulletMLRunner* , double)); 
  void BulletMLRunner_set_getBulletSpeedX(BulletMLRunner*, double (*fp) (BulletMLRunner* )); 
  void BulletMLRunner_set_getBulletSpeedY(BulletMLRunner*, double (*fp) (BulletMLRunner* )); 
  void BulletMLRunner_set_getRand(BulletMLRunner*, double (*fp) (BulletMLRunner* )); 
}

#endif


