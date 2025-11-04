import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { VietnamAddressService, Province, District, Ward } from './vietnam-address.service';

describe('VietnamAddressService', () => {
  let service: VietnamAddressService;
  let httpMock: HttpTestingController;
  const apiUrl = 'https://provinces.open-api.vn/api';

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [VietnamAddressService]
    });
    service = TestBed.inject(VietnamAddressService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpMock.verify();
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  it('should get provinces', () => {
    const mockProvinces: Province[] = [
      {
        code: 1,
        name: 'Hà Nội',
        name_en: 'Ha Noi',
        full_name: 'Thành phố Hà Nội',
        full_name_en: 'Ha Noi City',
        code_name: 'ha_noi'
      },
      {
        code: 79,
        name: 'TP. Hồ Chí Minh',
        name_en: 'Ho Chi Minh',
        full_name: 'Thành phố Hồ Chí Minh',
        full_name_en: 'Ho Chi Minh City',
        code_name: 'ho_chi_minh'
      }
    ];

    service.getProvinces().subscribe(provinces => {
      expect(provinces.length).toBe(2);
      expect(provinces[0].label).toBe('Hà Nội');
      expect(provinces[0].value).toBe(1);
    });

    const req = httpMock.expectOne(`${apiUrl}/p/`);
    expect(req.request.method).toBe('GET');
    req.flush(mockProvinces);
  });

  it('should get districts by province code', () => {
    const mockResponse = {
      districts: [
        {
          code: 1,
          name: 'Quận Ba Đình',
          name_en: 'Ba Dinh District',
          full_name: 'Quận Ba Đình',
          full_name_en: 'Ba Dinh District',
          code_name: 'ba_dinh',
          province_code: 1
        }
      ] as District[]
    };

    service.getDistricts(1).subscribe(districts => {
      expect(districts.length).toBe(1);
      expect(districts[0].label).toBe('Quận Ba Đình');
      expect(districts[0].value).toBe(1);
    });

    const req = httpMock.expectOne(`${apiUrl}/p/1?depth=2`);
    expect(req.request.method).toBe('GET');
    req.flush(mockResponse);
  });

  it('should get wards by district code', () => {
    const mockResponse = {
      wards: [
        {
          code: 1,
          name: 'Phường Phúc Xá',
          name_en: 'Phuc Xa Ward',
          full_name: 'Phường Phúc Xá',
          full_name_en: 'Phuc Xa Ward',
          code_name: 'phuc_xa',
          district_code: 1
        }
      ] as Ward[]
    };

    service.getWards(1).subscribe(wards => {
      expect(wards.length).toBe(1);
      expect(wards[0].label).toBe('Phường Phúc Xá');
      expect(wards[0].value).toBe(1);
    });

    const req = httpMock.expectOne(`${apiUrl}/d/1?depth=2`);
    expect(req.request.method).toBe('GET');
    req.flush(mockResponse);
  });

  it('should get province name by code', () => {
    const mockProvince: Province = {
      code: 1,
      name: 'Hà Nội',
      name_en: 'Ha Noi',
      full_name: 'Thành phố Hà Nội',
      full_name_en: 'Ha Noi City',
      code_name: 'ha_noi'
    };

    service.getProvinceName(1).subscribe(name => {
      expect(name).toBe('Hà Nội');
    });

    const req = httpMock.expectOne(`${apiUrl}/p/1`);
    expect(req.request.method).toBe('GET');
    req.flush(mockProvince);
  });

  it('should get district name by code', () => {
    const mockDistrict: District = {
      code: 1,
      name: 'Quận Ba Đình',
      name_en: 'Ba Dinh District',
      full_name: 'Quận Ba Đình',
      full_name_en: 'Ba Dinh District',
      code_name: 'ba_dinh',
      province_code: 1
    };

    service.getDistrictName(1).subscribe(name => {
      expect(name).toBe('Quận Ba Đình');
    });

    const req = httpMock.expectOne(`${apiUrl}/d/1`);
    expect(req.request.method).toBe('GET');
    req.flush(mockDistrict);
  });

  it('should get ward name by code', () => {
    const mockWard: Ward = {
      code: 1,
      name: 'Phường Phúc Xá',
      name_en: 'Phuc Xa Ward',
      full_name: 'Phường Phúc Xá',
      full_name_en: 'Phuc Xa Ward',
      code_name: 'phuc_xa',
      district_code: 1
    };

    service.getWardName(1).subscribe(name => {
      expect(name).toBe('Phường Phúc Xá');
    });

    const req = httpMock.expectOne(`${apiUrl}/w/1`);
    expect(req.request.method).toBe('GET');
    req.flush(mockWard);
  });
});

